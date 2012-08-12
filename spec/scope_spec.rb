class NSSortDescriptor
  def inspect
    description
  end

  def ==(other)
    description == other.description
  end
end

class TestScope < MotionData::Scope
  def array
    @target
  end
end

module MotionData

  describe Scope do
    it "initializes with a target" do
      target = []
      scope = TestScope.alloc.initWithTarget(target)
      scope.target.object_id.should == target.object_id
    end

    it "enumerates over the array version of the scope" do
      target = [21, 42]
      scope = TestScope.alloc.initWithTarget(target)
      scope.map { |object| object }.should == target
    end

    it "makes a copy of the given sort descriptors" do
      descriptors = [Object.new]
      scope = TestScope.alloc.initWithTarget([], predicate:nil, sortDescriptors:descriptors)
      scope.sortDescriptors.should == descriptors
      scope.sortDescriptors.object_id.should.not == descriptors.object_id
    end

    it "assigns the same target to a child scope" do
      scope = Scope.alloc.initWithTarget(Object.new)
      scope.where(:name => 'bob').target.should == scope.target
    end
  end

  describe Scope, "when building a new scope by adding finder conditions" do
    extend Predicate::Builder::Mixin

    it "from a hash" do
      scope1 = Scope.new

      scope2 = scope1.where(:name => 'bob', :amount => 42)
      scope2.predicate.predicateFormat.should == 'name == "bob" AND amount == 42'

      scope3 = scope2.where(:enabled => true)
      scope3.predicate.predicateFormat.should == '(name == "bob" AND amount == 42) AND (enabled == 1)'
    end

    it "from a scope" do
      scope1 = Scope.new

      scope2 = scope1.where(( value(:name).caseInsensitive != 'bob' ).or( value(:amount) > 42 )).sortBy(:name)
      scope3 = scope1.where(( value(:enabled) == true ).and( value('job.title') != nil )).sortBy(:amount, ascending:false)

      scope4 = scope3.where(scope2)
      scope4.predicate.predicateFormat.should == '(enabled == 1 AND job.title != nil) AND (name !=[c] "bob" OR amount > 42)'
      scope4.sortDescriptors.should == [
        NSSortDescriptor.alloc.initWithKey('amount', ascending:false),
        NSSortDescriptor.alloc.initWithKey('name', ascending:true)
      ]
    end

    it "from a NSPredicate" do
      scope1 = Scope.new

      scope2 = scope1.where(NSPredicate.predicateWithFormat('name != %@ OR amount > %@', argumentArray:['bob', 42]))
      scope2.predicate.predicateFormat.should == 'name != "bob" OR amount > 42'

      scope3 = scope2.where(NSPredicate.predicateWithFormat('enabled == 1'))
      scope3.predicate.predicateFormat.should == '(name != "bob" OR amount > 42) AND enabled == 1'
    end

    it "from a predicate string" do
      scope1 = Scope.new

      scope2 = scope1.where('name != %@ OR amount > %@', 'bob', 42)
      scope2.predicate.predicateFormat.should == 'name != "bob" OR amount > 42'

      scope3 = scope2.where('enabled == 1')
      scope3.predicate.predicateFormat.should == '(name != "bob" OR amount > 42) AND enabled == 1'
    end

    it "does not modify the original scopes" do
      scope1 = Scope.new

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
    it "sorts by a property" do
      scope1 = Scope.new.sortBy(:name, ascending:true)
      scope1.sortDescriptors.should == [NSSortDescriptor.alloc.initWithKey('name', ascending:true)]

      scope2 = scope1.sortBy(:amount, ascending:false)
      scope2.sortDescriptors.should == [
        NSSortDescriptor.alloc.initWithKey('name', ascending:true),
        NSSortDescriptor.alloc.initWithKey('amount', ascending:false)
      ]
    end

    it "sorts by a property and ascending" do
      scope = Scope.new.sortBy(:name)
      scope.sortDescriptors.should == [NSSortDescriptor.alloc.initWithKey('name', ascending:true)]
    end

    it "sorts by a NSSortDescriptor" do
      sortDescriptor = NSSortDescriptor.alloc.initWithKey('amount', ascending:true)
      scope = Scope.new.sortBy(sortDescriptor)
      scope.sortDescriptors.should == [sortDescriptor]
    end

    it "does not modify the original scope" do
      scope1 = Scope.new

      scope2 = scope1.sortBy(:name)
      scope2.object_id.should.not == scope1.object_id
      scope2.sortDescriptors.size.should == scope1.sortDescriptors.size + 1

      scope3 = scope2.sortBy(:name, ascending:false)
      scope3.object_id.should.not == scope2.object_id
      scope3.sortDescriptors.size.should == scope2.sortDescriptors.size + 1

      scope4 = scope3.sortBy(NSSortDescriptor.alloc.initWithKey('amount', ascending:true))
      scope4.object_id.should.not == scope3.object_id
      scope4.sortDescriptors.size.should == scope3.sortDescriptors.size + 1
    end
  end

  shared "Scope::Set#set" do
    extend Predicate::Builder::Mixin

    before do
      @scope = Scope::Set.alloc.initWithTarget(@set)
    end

    it "returns the original set when there are no finder or sort conditions" do
      @scope.set.object_id.should == @set.object_id
    end

    it "returns a set derived from the original set by applying the finder conditions" do
      scope = @scope.where(( value(:name) == 'bob' ).or( value(:name) == 'appie' ))
      scope.set.should == set(@appie, @bob)
    end

    it "returns an ordered set if sort conditions have been assigned" do
      @scope.sortBy(:name).set.should == NSOrderedSet.orderedSetWithArray([@alfred, @appie, @bob])
    end

    it "returns an array representation" do
      scope = @scope.where(( value(:name) == 'bob' ).or( value(:name) == 'appie' ))
      scope.sortBy(:name).map { |object| object }.should == [@appie, @bob]
    end
  end

  describe Scope::Set, "#set" do
    before do
      @appie  = { 'name' => 'appie' }
      @bob    = { 'name' => 'bob' }
      @alfred = { 'name' => 'alfred' }
    end

    describe "with a unordered set" do
      def set(*objects)
        NSSet.setWithArray(objects)
      end

      before do
        @set = set(@appie, @bob, @alfred)
      end

      behaves_like "Scope::Set#set"
    end

    describe "with a ordered set" do
      def set(*objects)
        NSOrderedSet.orderedSetWithArray(objects)
      end

      before do
        @set = set(@appie, @bob, @alfred)
      end

      behaves_like "Scope::Set#set"
    end
  end

  describe Scope::Relationship do
    before do
      MotionData.setupCoreDataStackWithInMemoryStore

      @context = Context.context
      @context.perform do
        @author = Author.new(:name => 'Edgar Allan Poe')
        Article.new(:author => @author, :title => 'article1', :published => true)
        Article.new(:author => @author, :title => 'article2')
        Article.new(:author => @author, :title => 'article3', :published => true)
      end

      @articles = Scope::Relationship.alloc.initWithTarget(@author.primitiveValueForKey('articles'),
                                          relationshipName: :articles,
                                                     owner:@author,
                                                ownerClass:Author)
    end

    it "wraps a Core Data relationship set" do
      @articles.set.should == @author.primitiveValueForKey('articles')

      scope = @articles.where(:published => true).sortBy(:title)
      scope.map(&:title).should == %w{ article1 article3 }
    end

    it "inserts a new instance of the destination entity in the owner's context and associates it to the owner" do
      article = @articles.new(:title => 'article4', :published => true)
      article.author.should == @author
      article.managedObjectContext.should == @context

      scope = @articles.where(:published => true).sortBy(:title)
      scope.map(&:title).should == %w{ article1 article3 article4 }
    end

    it "returns a NSFetchRequest that represents the scope" do
      request = @articles.fetchRequest
      request.entity.should == Article.entityDescription
      request.sortDescriptors.should == nil

      format = request.predicate.predicateFormat
      format.should == NSPredicate.predicateWithFormat('author == %@', argumentArray:[@author]).predicateFormat

      scope = @articles.where(:published => true).sortBy(:title)
      request = scope.fetchRequest
      request.entity.should == Article.entityDescription
      request.sortDescriptors.should == scope.sortDescriptors

      predicate = NSPredicate.predicateWithFormat('author == %@', argumentArray:[@author])
      predicate = predicate.and(scope.predicate)
      request.predicate.predicateFormat.should == predicate.predicateFormat
    end

    it "is able to use named scopes of the target model class" do
      @articles.published.should.be.instance_of Scope::Relationship
      @articles.published.target.should == @articles.target
      @articles.published.sortDescriptors.should == []
      @articles.published.predicate.predicateFormat.should == 'published == 1'

      @articles.published.withTitle.should.be.instance_of Scope::Relationship
      @articles.published.withTitle.target.should == @articles.target
      @articles.published.withTitle.sortDescriptors.should == [NSSortDescriptor.alloc.initWithKey('title', ascending:false)]
      @articles.published.withTitle.predicate.predicateFormat.should == '(published == 1) AND title != nil'
    end
  end

  describe Scope::Model do
    before do
      MotionData.setupCoreDataStackWithInMemoryStore

      Article.new(:title => 'article1', :published => true)
      @unpublishedArticle = Article.new(:title => 'article2', :published => false)
      Article.new(:title => 'article3', :published => true)
    end

    it "returns a NSFetchRequest that represents the scope" do
      scope = Scope::Model.alloc.initWithTarget(Article)

      request = scope.fetchRequest
      request.entity.should == Article.entityDescription
      request.sortDescriptors.should == nil
      request.predicate.should == nil

      scope = scope.where(:published => true).sortBy(:title)
      request = scope.fetchRequest
      request.entity.should == Article.entityDescription
      request.sortDescriptors.should == scope.sortDescriptors
      request.predicate.predicateFormat.should == scope.predicate.predicateFormat
    end

    it "returns objects of the target class" do
      scope = Scope::Model.alloc.initWithTarget(Article)
      scope = scope.where(:published => true).sortBy(:title)
      scope.map(&:title).should == %w{ article1 article3 }
    end

    it "returns an unordered set representation of the scope when there are no sort descriptors" do
      scope = Scope::Model.alloc.initWithTarget(Article)
      scope = scope.where(:published => false)
      scope.set.should == NSSet.setWithObject(@unpublishedArticle)
    end

    it "returns an ordered set representation of the scope when there are sort descriptors" do
      scope = Scope::Model.alloc.initWithTarget(Article)
      scope = scope.where(:published => false).sortBy(:title)
      scope.set.should == NSOrderedSet.orderedSetWithObject(@unpublishedArticle)
    end

    it "is able to use named scopes of the target model class" do
      scope = Scope::Model.alloc.initWithTarget(Article)

      scope.published.should.be.instance_of Scope::Model
      scope.published.target.should == Article
      scope.published.sortDescriptors.should == []
      scope.published.predicate.predicateFormat.should == 'published == 1'

      scope.published.withTitle.should.be.instance_of Scope::Model
      scope.published.withTitle.target.should == Article
      scope.published.withTitle.sortDescriptors.should == [NSSortDescriptor.alloc.initWithKey('title', ascending:false)]
      scope.published.withTitle.predicate.predicateFormat.should == '(published == 1) AND title != nil'
    end
  end
end
