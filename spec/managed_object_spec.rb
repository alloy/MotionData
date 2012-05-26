describe "MotionData::ManagedObject" do

  before do
    MotionData::Schema.current.setupCoreDataStackWithInMemoryStore
  end

  after do
    MagicalRecord.cleanUp
  end

  describe "property types" do
    it "includes String support" do
      author = Author.new
      author.name = "Edgar Allan Poe"
      author.name.should == "Edgar Allan Poe"
    end
  end

  describe "initialization" do
    describe "concerning context" do
      it "by default uses NSManagedObjectContext.defaultContext" do
        Author.new.managedObjectContext.should == NSManagedObjectContext.defaultContext
      end

      it "optionally uses an explicit different context" do
        context = NSManagedObjectContext.context
        author = Author.newInContext(context)
        author.managedObjectContext.should == context
        author.managedObjectContext.should.not == NSManagedObjectContext.defaultContext
      end
    end

    it "assigns the optionally given properties to the instance" do
      Author.new(:name => "Edgar Allan Poe").name.should == "Edgar Allan Poe"
      Author.newInContext(NSManagedObjectContext.context, :name => "Edgar Allan Poe").name.should == "Edgar Allan Poe"
    end
  end

end
