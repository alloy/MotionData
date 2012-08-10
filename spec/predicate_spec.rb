module MotionData

  describe Predicate::KeyPathExpression do
    extend Predicate::KeyPathExpression::Mixin

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
  end

  describe Predicate do
    extend Predicate::KeyPathExpression::Mixin

    it "returns a compound `AND` predicate" do
      predicate = (key(:amount) < 42).and(key(:amount) > 42)
      predicate.predicateFormat.should == 'amount < 42 AND amount > 42'
    end

    it "returns a compound `OR` predicate" do
      predicate = (key(:amount) < 42).or(key(:amount) > 42)
      predicate.predicateFormat.should == 'amount < 42 OR amount > 42'
    end
  end

end
