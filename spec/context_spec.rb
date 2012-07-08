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

    it "returns the main context as the current context on the main thread" do
      Context.current.should == Context.main
    end

    it "by default has no current context on other threads" do
      on_thread { Context.current == nil }.should == true
    end

    it "can temporarily override the current context on only the current thread" do
      context = Context.context

      Context.withCurrent(context) do
        # main thread
        Context.current.should == context
        # other thread
        on_thread { Context.current == nil }.should == true
      end

      on_thread do
        Context.withCurrent(context) do
          Context.current == context
        end
      end.should == true
    end

    # TODO RM bug: always prints exception, even if it's rescued.
    it "ensures the default context reverts after a withDefault block in case of an exception" do
      exception = nil
      begin
        context = Context.context
        Context.withCurrent(context) do
          raise "ohnoes!"
        end
      rescue Object => exception
      end
      exception.message.should == "ohnoes!"
      Context.current.should == Context.main
    end

    describe "concerning performing work on the context" do
      it "changes the current context for the duration of the block which is performed asynchronously" do
        context = Context.context
        thread  = Thread.current
        @result = false

        return_value = context.perform(:background => true) do |c|
          # first save the status, but don't save into @result yet
          r = Thread.current != thread && Context.current == context && c == context
          sleep 0.1
          # after 0.1s save into @result
          @result = r
          :from_block
        end
        return_value.should == nil

        @result.should == false
        wait 0.3 do
          @result.should == true
        end
      end

      it "changes the current context for the duration of the block which is performed synchronously" do
        context = Context.context
        thread  = Thread.current
        @result = false

        return_value = context.perform do |c|
          r = Thread.current == thread && Context.current == context && c == context
          sleep 0.1
          @result = r
          :from_block
        end
        return_value.should == :from_block
        @result.should == true
      end
    end

    describe "concerning transactional saving to the parent context" do
      it "yields a Context instance that is a child of the context" do
        @result = false
        Context.main.transaction do |localContext|
          @result = localContext.instance_of?(Context) &&
                      Context.current == localContext &&
                        localContext.parentContext == Context.main
        end
        @result.should == true
      end

      it "merges the changes into the parent context afterwards" do
        Context.main.transaction :background => true do
          Author.new(:name => "Edgar Allan Poe")
          sleep 0.1
        end
        Author.all.size.should == 0
        wait 0.3 do
          Author.all.map(&:name).should == ["Edgar Allan Poe"]
        end
      end
    end
  end

end
