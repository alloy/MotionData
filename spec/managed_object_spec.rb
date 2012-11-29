module MotionData

  describe ManagedObject do

    before do
      MotionData.setupCoreDataStackWithInMemoryStore
    end

    after do
      #MagicalRecord.cleanUp
    end

    it "returns wether or not it's an actual model class defined by the user or a dynamic subclass defined by Core Data" do
      Author.should.not.be.dynamicSubclass
      Author.new.class.should.be.dynamicSubclass
    end

    it "always returns the model class defined by the user, not the dynamic subclass defined by Core Data" do
      Author.modelClass.should == Author
      Author.new.class.modelClass.should == Author
    end

    it "always returns the entity description of the model class defined by the user, not from the dynamic subclass defined by Core Data" do
      Author.entityDescription.name.should == 'Author'
      Author.entityDescription.managedObjectClassName.should == 'Author'
      Author.new.class.entityDescription.name.should == 'Author'
      Author.new.class.entityDescription.managedObjectClassName.should == 'Author'
    end

    describe "property definitions" do
      it "includes String support" do
        author = Author.new
        author.name = "Edgar Allan Poe"
        author.name.should == "Edgar Allan Poe"
      end

      it "includes Float support" do
        author = Author.new
        author.fee = 200.00
        author.fee.should == 200.00
        author.fee.class.should == Float
      end

      it "includes Time support" do
        article = Article.new
        article.publishedAt = time = Time.now
        article.publishedAt.should == time
        article.publishedAt.class.should == Time
      end

      it "includes Integer32 support" do
        article = Article.new
        article.length = 2147483647
        article.length.should == 2147483647
      end


      it "generates a predicate method to access a boolean property which returns false/false instead of 0/1" do
        article = Article.new
        article.published?.should == false
        article.published = true

        article = Article.all.to_a.first
        article.published?.should == true
      end

      it "by default uses the default value" do
        Article.new.should.not.be.published
        Article.new(:published => true).should.be.published
      end
    end

    describe "initialization" do
      it "assigns the optionally given properties to the instance" do
        Author.new(:name => "Edgar Allan Poe").name.should == "Edgar Allan Poe"
        Author.newInContext(Context.context, :name => "Edgar Allan Poe").name.should == "Edgar Allan Poe"
      end

      describe "concerning context" do
        it "by default uses Context.main" do
          Author.new.managedObjectContext.should == Context.main
        end

        it "optionally uses an explicit different context" do
          context = Context.context
          Author.newInContext(context).managedObjectContext.should == context
        end
      end
    end

    describe "scopes" do
      it "returns all entities of a managed object in the current context" do
        Author.all.to_a.should == []
        Author.new(:name => "Edgar Allan Poe")
        Author.all.map(&:name).should == ["Edgar Allan Poe"]
      end

      it "defines a named scope" do
        Author.scope(:edgars, Author.where(:name => 'edgar'))
        Author.edgars.target.should == Author
        Author.edgars.predicate.predicateFormat.should == 'name == "edgar"'
      end

      it "extends the normal Core Data relationship set to act like a Scope::Relationship" do
        author = Author.new
        author.articles.should.is_a? Scope::Relationship::SetExt
        author.articles.__scope__.owner.should == author
        author.articles.to_a.should == []

        article1 = author.articles.new(:title => 'article1')
        article2 = author.articles.new(:title => 'article2')
        author.articles.published.withTitle.to_a.should == []
        article1.published = true; article2.published = true
        author.articles.published.withTitle.to_a.should == [article2, article1]
      end
    end
  end

end
