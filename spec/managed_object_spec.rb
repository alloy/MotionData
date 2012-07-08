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

    #describe "concerning saving on a background thread" do
      #it "merges the changes into the default context afterwards" do
        #MotionData::ManagedObject.saveInBackground do
          #Author.new(:name => "Edgar Allan Poe")
        #end
        #Author.numberOfEntities.should == 0
        #wait 0.1 do
          #Author.findAll.map(&:name).should == ["Edgar Allan Poe"]
        #end
      #end
    #end

  end

end
