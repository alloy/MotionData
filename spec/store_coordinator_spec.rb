module MotionData

  describe StoreCoordinator do
    it "returns an in memory store with the given schema" do
      store = StoreCoordinator.inMemory(Schema.current)
      store.managedObjectModel.should == Schema.current
      store.persistentStores.first.type.should == NSInMemoryStoreType
    end
  end

end
