module MotionData

  describe ComparableKeyPathExpression do
    extend ComparableKeyPathExpression::Mixin

    it "returns a expression for the left-hand side of a comparison" do
      value(:property).expression.keyPath.should == 'property'
      value('property.subproperty').expression.keyPath.should == 'property.subproperty'
    end

    it "returns comparison predicates" do
      {
        (value(:amount)  < 42) => 'amount < 42',
        (value(:amount)  > 42) => 'amount > 42',
        (value(:amount) <= 42) => 'amount <= 42',
        (value(:amount) >= 42) => 'amount >= 42',
        (value(:amount) != 42) => 'amount != 42',
        (value(:amount) == 42) => 'amount == 42',

        value(:amount).between?(21, 42) => 'amount BETWEEN {21, 42}',
        value(:amount).in?([21, 42])    => 'amount IN {21, 42}',
        value(:amount).include?(42)     => 'amount CONTAINS 42',
        value(:name).beginsWith?('bob') => 'name BEGINSWITH "bob"',
        value(:name).endsWith?('bob')   => 'name ENDSWITH "bob"',
      }.each do |predicate, format|
        predicate.predicateFormat.should == format
      end
    end

    it "negates the comparison predicate" do
      value(:name).not.beginsWith?('bob').predicateFormat.should == 'NOT name BEGINSWITH "bob"'
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

  describe NSPredicate do
    extend ComparableKeyPathExpression::Mixin

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
