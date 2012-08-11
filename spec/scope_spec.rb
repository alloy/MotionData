class NSSortDescriptor
  def inspect
    description
  end

  def ==(other)
    description == other.description
  end
end

module MotionData

  describe Scope do
    it "initializes with a class target and current context" do
      scope = Scope.alloc.initWithTarget(Author)
      scope.target.should == Author
      scope.context.should == Context.current
    end

    it "stores a copy of the given sort descriptors" do
      
    end
  end

  describe Scope, "when building a new scope by adding finder conditions" do
    extend Predicate::Builder::Mixin

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
      scope1 = Scope.alloc.initWithTarget(Author)

      scope2 = scope1.where(:name => 'bob')
      scope2.object_id.should.not == scope1.object_id
      scope2.predicate.object_id.should.not == scope1.predicate.object_id

      scope3 = scope2.where(value(:name) == 'bob')
      scope3.object_id.should.not == scope2.object_id
      scope3.predicate.object_id.should.not == scope2.predicate.object_id

      scope4 = scope3.where('name == %@', 'bob')
      scope4.object_id.should.not == scope3.object_id
      scope4.predicate.object_id.should.not == scope3.predicate.object_id

      scope5 = scope4.where(NSPredicate.predicateWithFormat('name == "bob"'))
      scope5.object_id.should.not == scope4.object_id
      scope5.predicate.object_id.should.not == scope4.predicate.object_id
    end
  end

  describe Scope, "when building a new scope by adding sort conditions" do
    extend Predicate::Builder::Mixin

    it "sorts by a property" do
      scope1 = Scope.alloc.initWithTarget(Author)

      scope2 = scope1.sortBy(:name, ascending:true)
      scope2.object_id.should.not == scope1.object_id
      scope2.sortDescriptors.should == [NSSortDescriptor.alloc.initWithKey('name', ascending:true)]

      scope3 = scope2.sortBy(:amount, ascending:false)
      scope3.object_id.should.not == scope2.object_id
      scope3.sortDescriptors.should == [
        NSSortDescriptor.alloc.initWithKey('name', ascending:true),
        NSSortDescriptor.alloc.initWithKey('amount', ascending:false)
      ]
    end
  end

end
