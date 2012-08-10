module MotionData

  describe Predicate::ComparableKeyPathExpression do
    extend Predicate::ComparableKeyPathExpression::Mixin

    it "returns a expression for the left-hand side of a comparison" do
      key(:property).expression.keyPath.should == 'property'
      keyPath('property.subproperty').expression.keyPath.should == 'property.subproperty'
    end

    it "returns comparison predicates" do
      {
        (key(:amount)  < 42) => 'amount < 42',
        (key(:amount)  > 42) => 'amount > 42',
        (key(:amount) <= 42) => 'amount <= 42',
        (key(:amount) >= 42) => 'amount >= 42',
        (key(:amount) != 42) => 'amount != 42',
        (key(:amount) == 42) => 'amount == 42',
      }.each do |predicate, format|
        predicate.predicateFormat.should == format
      end
    end

    it "returns a `between` predicate" do
      predicate = key(:amount).between?(21, 42)
      predicate.predicateFormat.should == 'amount BETWEEN {21, 42}'
    end

    it "returns a `in` predicate" do
      predicate = key(:amount).in?([21, 42])
      predicate.predicateFormat.should == 'amount IN {21, 42}'
    end

    it "returns a `contains` predicate" do
      predicate = key(:amount).include?(42)
      predicate.predicateFormat.should == 'amount CONTAINS 42'
    end

    it "returns a `in collection` predicate" do
      predicate = key(:amount).in?([21, 42])
      predicate.predicateFormat.should == 'amount IN {21, 42}'
    end

    it "returns a `begin's with` predicate" do
      predicate = key(:name).beginsWith?('bob')
      predicate.predicateFormat.should == 'name BEGINSWITH "bob"'
    end

    it "returns a `end's with` predicate" do
      predicate = key(:name).endsWith?('bob')
      predicate.predicateFormat.should == 'name ENDSWITH "bob"'
    end


    it "by default returns that no comparison options should be used" do
      key(:property).comparisonOptions.should == 0
    end

    it "adds the option to perform a case-insensitive comparison" do
      expression = key(:name)
      expression.caseInsensitive.object_id.should == expression.object_id
      expression.comparisonOptions.should == NSCaseInsensitivePredicateOption
    end

    it "adds the option to perform a diacritic-insensitive comparison" do
      expression = key(:name)
      expression.diacriticInsensitive.object_id.should == expression.object_id
      expression.comparisonOptions.should == NSDiacriticInsensitivePredicateOption
    end

    it "adds the option to perform a locale-sensitive comparison" do
      expression = key(:name)
      expression.localeSensitive.object_id.should == expression.object_id
      expression.comparisonOptions.should == NSLocaleSensitivePredicateOption
    end

    it "combines comparison options" do
      options = key(:name).caseInsensitive.diacriticInsensitive.localeSensitive.comparisonOptions
      options.should == NSCaseInsensitivePredicateOption |
                        NSDiacriticInsensitivePredicateOption |
                        NSLocaleSensitivePredicateOption
    end

    it "adds the accumulated comparison options to the comparison" do
      predicate = key(:name).caseInsensitive.diacriticInsensitive == 'bob'
      predicate.predicateFormat.should == 'name ==[cd] "bob"'
    end
  end

  describe Predicate do
    extend Predicate::ComparableKeyPathExpression::Mixin

    it "returns a compound `AND` predicate" do
      predicate = (key(:amount) < 42).and(key(:amount) > 42).and(key(:amount) != 21)
      predicate.predicateFormat.should == '(amount < 42 AND amount > 42) AND amount != 21'
    end

    it "returns a compound `OR` predicate" do
      predicate = (key(:amount) < 42).or(key(:amount) > 42).or(key(:amount) != 21)
      predicate.predicateFormat.should == '(amount < 42 OR amount > 42) OR amount != 21'
    end
  end

end
