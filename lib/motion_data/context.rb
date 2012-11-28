module MotionData
  class Context < NSManagedObjectContext
    class << self
      attr_accessor :root, :main

      # This returns the default context for the current thread. On the main
      # thread this will be `Context.main` and on other threads this will lazy
      # load (and cache) a context through `Context.context`
      def current
        Thread.current[:motionDataCurrentContext] || (main if NSThread.mainThread?)
      end

      def withCurrent(context)
        Thread.current[:motionDataCurrentContext] = context
        yield
      ensure
        Thread.current[:motionDataCurrentContext] = nil
      end

      # This is the root context for all contexts managed by MotionData, which
      # is used to actually save data to the persistent store.
      #
      # This context is a `NSPrivateQueueConcurrencyType`, which means it can
      # perform saves in the background.
      def root
        unless @root
          @root = new
          @root.persistentStoreCoordinator = StoreCoordinator.default # MR does this in performBlockAndWait. Why?
        end
        @root
      end

      # This is the context that is intended for all the foreground work, such
      # as providing data to your view controllers.
      #
      # Background contexts are children of this context, which means that they
      # save their data into this context, allowing you to show data when it’s
      # not yet saved to the persistent store.
      def main
        @main ||= new(root, NSMainQueueConcurrencyType)
      end

      # debugging information on the current thread and context
      def reportContext( message )
        threading = NSThread.mainThread? ? "on MAIN thread" : "on background thread"
        if current == main
          NSLog "MAIN context #{threading} :#{message}"
        elsif current == root
          NSLog "ROOT context #{threading} :#{message}"
        else
          NSLog "#{current} context #{threading} :#{message}"
        end
      end

      # Returns a new private queue context that is a child of the main context.
      #
      # These are used to perform work in the background and then push that to
      # the main queue.
      def context
        main.context
      end

      # MotionData contexts are, besides the main context, always of type
      # NSPrivateQueueConcurrencyType.
      def new(parent = nil, concurrencyType = NSPrivateQueueConcurrencyType)
        context = alloc.initWithConcurrencyType(concurrencyType)
        context.parentContext = parent if parent # do NOT set `nil`
        context
      end
    end

    # Returns a new private queue context that is a child of the this context.
    #
    # These are used to perform work in the background and then push that to
    # the main queue.
    def context
      self.class.new(self)
    end

    # Performs a block on the context's dispatch queue, while changing
    # `Context.current` to the context for the duration of the block.
    #
    # Options:
    #
    # * `:background` - If `true` the block is executed asynchronously.
    #                   Otherwise, the block is performed synchronously and the
    #                   result of the block is returned.
    #
    # Optionally yields the context.
    def perform(options = {}, &block)
      result = nil
      work   = lambda do
        Context.withCurrent(self) do
          result = block.call(self)
        end
      end
      options[:background] ? performBlock(work) : performBlockAndWait(work)
      result
    end

    # TODO return whether or not the save was a success
    def transaction(options = {}, &block)
      c = context
      c.perform(options, &block)
      c.perform(options) do

        error_ptr = Pointer.new(:object)
        unless c.save(error_ptr) 
          error = error_ptr[0]
          puts "Error when saving data: #{error.localizedDescription}"
          if !error.userInfo['NSDetailedErrors'].nil?
            error.userInfo['NSDetailedErrors'].each do |key, value|
              puts "#{key}: #{value}"
            end
          end 
          raise "Error when saving data: #{error.localizedDescription}"
        end
      end
    end

    def objectsInContext(*objectsFromOtherContext)
      objectsFromOtherContext.map { |object| objectWithID(object.objectID) }
    end

    def saveChanges
      error_ptr = Pointer.new(:object)
      unless save(error_ptr)
        error = error_ptr[0]
        puts "Error when saving data: #{error.localizedDescription}"
        if !error.userInfo['NSDetailedErrors'].nil?
          error.userInfo['NSDetailedErrors'].each do |key, value|
            puts "#{key}: #{value}"
          end
        end
        raise "Error when saving data: #{error.localizedDescription}"
      end
    end
  end
end
