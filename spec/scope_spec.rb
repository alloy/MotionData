module MotionData

  describe Scope do
    extend Predicate::ComparableKeyPathExpression::Mixin

    it "initializes with a class target and current context" do
      scope = Scope.alloc.initWithTarget(Author)
      scope.target.should == Author
      scope.context.should == Context.current
    end
  end

  describe Scope, "when building a new scope by applying finder options" do
    extend Predicate::ComparableKeyPathExpression::Mixin

    it "from a hash" do
      scope1 = Scope.alloc.initWithTarget(Author)

      scope2 = scope1.where(:name => 'bob', :amount => 42)
      scope2.should.not == scope1
      scope2.predicate.predicateFormat.should == 'name == "bob" AND amount == 42'

      scope3 = scope2.where(:enabled => true)
      scope3.should.not == scope2
      scope3.predicate.predicateFormat.should == '(name == "bob" AND amount == 42) AND (enabled == 1)'
    end

    it "from a predicate" do
      scope1 = Scope.alloc.initWithTarget(Author)

      #scope2 = scope1.where(( value(:name) != 'bob' ).or( value(:amount) > 42 ))
      scope2 = scope1.where(( key(:name) != 'bob' ).or( key(:amount) > 42 ))
      scope2.should.not == scope1
      scope2.predicate.predicateFormat.should == 'name != "bob" OR amount > 42'

      scope3 = scope2.where( key(:enabled) == true )
      scope3.should.not == scope2
      scope3.predicate.predicateFormat.should == '(name != "bob" OR amount > 42) AND enabled == 1'
    end

    it "from a scope" do
      scope1 = Scope.alloc.initWithTarget(Author)
      scope2 = scope1.where(( key(:name).caseInsensitive != 'bob' ).or( key(:amount) > 42 ))
      scope3 = scope1.where(( key(:enabled) == true ).and( key(:title) != nil ))

      scope4 = scope3.where(scope2)
      scope4.should.not == scope3
      scope4.predicate.predicateFormat.should == '(enabled == 1 AND title != nil) AND (name !=[c] "bob" OR amount > 42)'
    end
  end

end
