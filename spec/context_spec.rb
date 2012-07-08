module MotionData

  describe Context do

    before do
      MotionData.setupCoreDataStackWithInMemoryStore
    end

    after do
      #MagicalRecord.cleanUp
    end

    it "returns a root context, which is used to actually save to the persistent store" do
      Context.root.should.be.instance_of Context
      Context.root.concurrencyType.should == NSPrivateQueueConcurrencyType
      Context.root.parentContext.should == nil
      Context.root.persistentStoreCoordinator.should == StoreCoordinator.default
    end

    it "has a main context, which is intended to be used for foreground work (e.g. controllers)" do
      Context.main.should.be.instance_of Context
      Context.main.concurrencyType.should == NSMainQueueConcurrencyType
      Context.main.parentContext.should == Context.root
    end

    it "returns a new private queue context that is a child of the main context" do
      c = Context.context
      c.should.be.instance_of Context
      c.concurrencyType.should == NSPrivateQueueConcurrencyType
      c.parentContext.should == Context.main
    end

    it "returns the main context as the default context on the main thread" do
      Context.default.should == Context.main
    end

    it "by default has no default context on other threads" do
      on_thread { Context.default == nil }.should == true
    end

    it "can temporarily override the default context on only the current thread" do
      context = Context.context

      Context.withDefault(context) do
        # main thread
        Context.default.should == context
        # other thread
        on_thread { Context.default == nil }.should == true
      end

      on_thread do
        Context.withDefault(context) do
          Context.default == context
        end
      end.should == true
    end

    # TODO RM bug: always prints exception, even if it's rescued.
    it "ensures the default context reverts after a withDefault block in case of an exception" do
      exception = nil
      begin
        context = Context.context
        Context.withDefault(context) do
          raise "ohnoes!"
        end
      rescue Object => exception
      end
      exception.message.should == "ohnoes!"
      Context.default.should == Context.main
    end

    # TODO currently these methods yield the default context, I'm pretty sure
    # that's not supposed to be the case. Waiting to hear from Saul Mora.
    #
    #describe "concerning saving on a background thread" do
      ## This is to ensure that we properly fix MagicalRecord that would always return a NSManagedObjectContext
      ## TODO create patch
      #it "yields a MotionData::Context instance" do
        #localContextClass = nil
        #MotionData::ManagedObject.saveInBackground do |localContext|
          #localContextClass = localContext.class
        #end
        #wait 0.1 do
          #localContextClass.should == MotionData::Context
        #end
      #end

      #it "is performed in a seperate context" do
        #localContextIsChildOfDefaultContext = nil
        #MotionData::ManagedObject.saveInBackground do |localContext|
          #localContextIsChildOfDefaultContext = (localContext.parentContext == NSManagedObjectContext.defaultContext)
        #end
        #wait 0.1 do
          #localContextIsChildOfDefaultContext.should == true
        #end
      #end
    #end
  end

end
