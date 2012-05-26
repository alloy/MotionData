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

  # TODO currently these methods yield the default context, I'm pretty sure
  # that's not supposed to be the case. Waiting to hear from Saul Mora.
  #
  #describe "concerning saving on a background thread" do
    #it "is performed in a seperate context" do
      #context = nil
      #MotionData::ManagedObject.saveInBackground do |c|
        ##context = NSManagedObjectContext.contextForCurrentThread
        #context = c
      #end
      #puts 'waiting...'
      #wait 1 do
        #context.should.not == NSManagedObjectContext.defaultContext
      #end
    #end

    #it "merges the changes into the default context afterwards" do
      #MotionData::ManagedObject.saveInBackground do |c|
        #Author.new(:name => "Edgar Allan Poe")
      #end
      #Author.numberOfEntities.should == 0
      #puts 'waiting...'
      #wait 1 do
        #Author.findAll.map(&:name).should == ["Edgar Allan Poe"]
      #end
    #end
  #end

end
