module MotionData

  describe ManagedObject do

    before do
      MotionData.setupCoreDataStackWithInMemoryStore
    end

    after do
      #MagicalRecord.cleanUp
    end

    describe "property types" do
      it "includes String support" do
        author = Author.new
        author.name = "Edgar Allan Poe"
        author.name.should == "Edgar Allan Poe"
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
    end
  end

end
