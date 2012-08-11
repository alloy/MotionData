module MotionData

  describe ComparablevaluePathExpression do
    extend ComparablevaluePathExpression::Mixin

    it "returns a expression for the left-hand side of a comparison" do
      value(:property).expression.valuePath.should == 'property'
      valuePath('property.subproperty').expression.valuePath.should == 'property.subproperty'
    end

    it "returns comparison predicates" do
      {
        (value(:amount)  < 42) => 'amount < 42',
        (value(:amount)  > 42) => 'amount > 42',
        (value(:amount) <= 42) => 'amount <= 42',
        (value(:amount) >= 42) => 'amount >= 42',
        (value(:amount) != 42) => 'amount != 42',
        (value(:amount) == 42) => 'amount == 42',
      }.each do |predicate, format|
        predicate.predicateFormat.should == format
      end
    end

    it "returns a `between` predicate" do
      predicate = value(:amount).between?(21, 42)
      predicate.predicateFormat.should == 'amount BETWEEN {21, 42}'
    end

    it "returns a `in` predicate" do
      predicate = value(:amount).in?([21, 42])
      predicate.predicateFormat.should == 'amount IN {21, 42}'
    end

    it "returns a `contains` predicate" do
      predicate = value(:amount).include?(42)
      predicate.predicateFormat.should == 'amount CONTAINS 42'
    end

    it "returns a `in collection` predicate" do
      predicate = value(:amount).in?([21, 42])
      predicate.predicateFormat.should == 'amount IN {21, 42}'
    end

    it "returns a `begin's with` predicate" do
      predicate = value(:name).beginsWith?('bob')
      predicate.predicateFormat.should == 'name BEGINSWITH "bob"'
    end

    it "returns a `end's with` predicate" do
      predicate = value(:name).endsWith?('bob')
      predicate.predicateFormat.should == 'name ENDSWITH "bob"'
    end

    it "by default returns that no comparison options should be used" do
      value(:property).comparisonOptions.should == 0
    end

    it "adds the option to perform a case-insensitive comparison" do
      expression = value(:name)
      expression.caseInsensitive.object_id.should == expression.object_id
      expression.comparisonOptions.should == NSCaseInsensitivePredicateOption
    end

    it "adds the option to perform a diacritic-insensitive comparison" do
      expression = value(:name)
      expression.diacriticInsensitive.object_id.should == expression.object_id
      expression.comparisonOptions.should == NSDiacriticInsensitivePredicateOption
    end

    it "adds the option to perform a locale-sensitive comparison" do
      expression = value(:name)
      expression.localeSensitive.object_id.should == expression.object_id
      expression.comparisonOptions.should == NSLocaleSensitivePredicateOption
    end

    it "combines comparison options" do
      options = value(:name).caseInsensitive.diacriticInsensitive.localeSensitive.comparisonOptions
      options.should == NSCaseInsensitivePredicateOption |
                        NSDiacriticInsensitivePredicateOption |
                        NSLocaleSensitivePredicateOption
    end

    it "adds the accumulated comparison options to the comparison" do
      predicate = value(:name).caseInsensitive.diacriticInsensitive == 'bob'
      predicate.predicateFormat.should == 'name ==[cd] "bob"'
    end
  end

  describe Predicate do
    extend ComparablevaluePathExpression::Mixin

    it "returns a compound `AND` predicate" do
      predicate = ( value(:amount) < 42 ).and( value(:amount) > 42 ).and( value(:amount) != 21 )
      predicate.predicateFormat.should == '(amount < 42 AND amount > 42) AND amount != 21'
    end

    it "returns a compound `OR` predicate" do
      predicate = ( value(:amount) < 42 ).or( value(:amount) > 42 ).or( value(:amount) != 21 )
      predicate.predicateFormat.should == '(amount < 42 OR amount > 42) OR amount != 21'
    end
  end

end
