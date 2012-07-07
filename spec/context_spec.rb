describe "MotionData::Context" do

  before do
    MotionData::Schema.current.setupCoreDataStackWithInMemoryStore
  end

  after do
    MagicalRecord.cleanUp
  end

  it "has a default MotionData::Context instance" do
    MotionData::Context.default.should.be.instance_of MotionData::Context
  end

  # TODO currently these methods yield the default context, I'm pretty sure
  # that's not supposed to be the case. Waiting to hear from Saul Mora.
  #
  describe "concerning saving on a background thread" do
    # This is to ensure that we properly fix MagicalRecord that would always return a NSManagedObjectContext
    # TODO create patch
    it "yields a MotionData::Context instance" do
      localContextClass = nil
      MotionData::ManagedObject.saveInBackground do |localContext|
        localContextClass = localContext.class
      end
      wait 0.1 do
        localContextClass.should == MotionData::Context
      end
    end

    it "is performed in a seperate context" do
      localContextIsChildOfDefaultContext = nil
      MotionData::ManagedObject.saveInBackground do |localContext|
        localContextIsChildOfDefaultContext = (localContext.parentContext == NSManagedObjectContext.defaultContext)
      end
      wait 0.1 do
        localContextIsChildOfDefaultContext.should == true
      end
    end
  end
end
