class Schema < NSManagedObjectModel
  def self.instance
    @instance ||= new
  end

  def register_entity(entity_description)
    self.entities = entities.arrayByAddingObject(entity_description)
  end
end
