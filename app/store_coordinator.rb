module MotionData
  class StoreCoordinator < NSPersistentStoreCoordinator
    class << self
      attr_accessor :default

      def inMemory(schema)
        store = alloc.initWithManagedObjectModel(schema)
        store.addPersistentStoreWithType(NSInMemoryStoreType,
                           configuration:nil,
                                     URL:nil,
                                 options:nil,
                                  error:nil)
        # TODO handleError(error) unless store
        store
      end
    end
  end
end
