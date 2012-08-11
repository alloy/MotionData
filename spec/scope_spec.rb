module MotionData

  describe Scope do
    it "initializes with a class target and current context" do
      scope = Scope.alloc.initWithTarget(Author)
      scope.target.should == Author
      scope.context.should == Context.current
    end
  end

  describe Scope, "when building a new scope by applying finder options" do
    extend ComparableKeyPathExpression::Mixin

    it "from a hash" do
      scope1 = Scope.alloc.initWithTarget(Author)

      scope2 = scope1.where(:name => 'bob', :amount => 42)
      scope2.predicate.predicateFormat.should == 'name == "bob" AND amount == 42'

      scope3 = scope2.where(:enabled => true)
      scope3.predicate.predicateFormat.should == '(name == "bob" AND amount == 42) AND (enabled == 1)'
    end

    it "from a scope" do
      scope1 = Scope.alloc.initWithTarget(Author)

      scope2 = scope1.where(( value(:name).caseInsensitive != 'bob' ).or( value(:amount) > 42 ))
      scope3 = scope1.where(( value(:enabled) == true ).and( value('job.title') != nil ))

      scope4 = scope3.where(scope2)
      scope4.predicate.predicateFormat.should == '(enabled == 1 AND job.title != nil) AND (name !=[c] "bob" OR amount > 42)'
    end

    it "from a MotionData type predicate" do
      scope1 = Scope.alloc.initWithTarget(Author)

      scope2 = scope1.where( value(:name).beginsWith?('bob').or( value(:amount) > 42 ))
      scope2.predicate.predicateFormat.should == 'name BEGINSWITH "bob" OR amount > 42'

      scope3 = scope2.where( value(:enabled) == true )
      scope3.predicate.predicateFormat.should == '(name BEGINSWITH "bob" OR amount > 42) AND enabled == 1'
    end

    it "from a normal NSPredicate" do
      scope1 = Scope.alloc.initWithTarget(Author)

      scope2 = scope1.where(NSPredicate.predicateWithFormat('name != %@ OR amount > %@', argumentArray:['bob', 42]))
      scope2.predicate.predicateFormat.should == 'name != "bob" OR amount > 42'

      scope3 = scope2.where(NSPredicate.predicateWithFormat('enabled == 1'))
      scope3.predicate.predicateFormat.should == '(name != "bob" OR amount > 42) AND enabled == 1'
    end

    it "from a predicate string" do
      scope1 = Scope.alloc.initWithTarget(Author)

      scope2 = scope1.where('name != %@ OR amount > %@', 'bob', 42)
      scope2.predicate.predicateFormat.should == 'name != "bob" OR amount > 42'

      scope3 = scope2.where('enabled == 1')
      scope3.predicate.predicateFormat.should == '(name != "bob" OR amount > 42) AND enabled == 1'
    end

    it "does not modify the original scopes" do
      
    end
  end

end
