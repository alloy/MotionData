module MotionData
  class StoreCoordinator < NSPersistentStoreCoordinator
    class << self
      attr_accessor :default

      def inMemory(schema)
        store schema, NSInMemoryStoreType
      end

      def onDiskStore(schema, path)
        store schema, NSSQLiteStoreType, NSURL.fileURLWithPath(path)
      end

      private

      # TODO handleError(error) unless store
      def store(schema, type, url = nil)
        coordinator = alloc.initWithManagedObjectModel(schema)
        error = Pointer.new(:object)
        store = coordinator.addPersistentStoreWithType(type,
                                         configuration:nil,
                                                   URL:url,
                                               options:nil,
                                                 error:error)
        if store.nil?
          error[0].userInfo['metadata'].each do |key, value|
            puts "#{key}: #{value}"
          end
          raise error[0].userInfo['reason']
        end
        coordinator
      end
    end
  end
end
