module MotionData
  def self.setupCoreDataStackWithInMemoryStore
    Schema.current.setupCoreDataStackWithInMemoryStore
  end

  def self.setupCoreDataStackWithSQLiteStore(path)
    Schema.current.setupCoreDataStackWithSQLiteStore(path)
  end

  class EntityDescription < NSEntityDescription
    def property(name, type, options = {})
      ad = AttributeDescription.withReflection(:name => name, :type => type, :options => options)
      self.properties = properties.arrayByAddingObject(ad)
    end

    def hasOne(name, options = {})
      relationshipDescriptionWithOptions({ :name => name, :maxCount => 1 }.merge(options))
    end

    def hasMany(name, options = {})
      relationshipDescriptionWithOptions({ :name => name, :maxCount => -1 }.merge(options))
    end

    def modelClass
      @modelClass ||= Object.const_get(name)
    end

    private

    def relationshipDescriptionWithOptions(options)
      rd = NSRelationshipDescription.new
      inverseName = options.delete(:inverse)

      options.each do |key, value|
        rd.send("#{key}=", value)
      end

      # There is a chicken-and-egg problem, which is that the inverse
      # relationship doesn't exist yet, by the time this relationship is
      # defined, if this is the first model that defines a part of this
      # relationship.
      if inverseName && inverse = rd.destinationEntity.relationshipsByName[inverseName]
        rd.inverseRelationship = inverse
        inverse.inverseRelationship = rd
        #puts rd.debugDescription
        #puts
        #puts inverse.debugDescription
        #puts
      end

      self.properties = properties.arrayByAddingObject(rd)
    end
  end

  class AttributeDescription < NSAttributeDescription
    # This is stored mainly so it can easily be dumped by Schema#to_ruby.
    attr_accessor :attributeReflection

    def self.withReflection(reflection)
      ad = new
      ad.attributeReflection = reflection
      ad.name                = reflection[:name]
      ad.defaultValue        = reflection[:options][:default]
      ad.optional            = !reflection[:options][:required]

      type = reflection[:type]
      ad.attributeType = if type == String
                           NSStringAttributeType
                         elsif type == CoreTypes::Boolean
                           NSBooleanAttributeType
                         elsif type == CoreTypes::Transformable
                           NSTransformableAttributeType
                         elsif type == CoreTypes::Integer16
                           NSInteger16AttributeType
                         elsif type == CoreTypes::Integer32
                           NSInteger32AttributeType
                         elsif type == CoreTypes::Float
                           NSFloatAttributeType
                         elsif type == CoreTypes::Time
                           NSDateAttributeType
                         else
                           # Transient types?
                           NSUndefinedAttributeType
                         end
      ad
    end
  end

  class Schema < NSManagedObjectModel
    def self.current
      @current ||= defineVersion('current')
    end

    def self.defineVersion(version)
      schema = new
      schema.versionIdentifiers = NSSet.setWithObject(version)
      yield schema if block_given?
      schema
    end

    # Stack maintenance

    def setupCoreDataStackWithInMemoryStore
      Context.root = Context.main = nil
      StoreCoordinator.default = StoreCoordinator.inMemory(self)
    end

    def setupCoreDataStackWithSQLiteStore(path)
      Context.root = Context.main = nil
      StoreCoordinator.default = StoreCoordinator.onDiskStore(self, path)
    end

    # TODO handle errors!
    def migrateFromSchema(source)
      sourceModel, destinationModel = source.mappingModel, self.mappingModel
      if mappingModel = NSMappingModel.inferredMappingModelForSourceModel(sourceModel, destinationModel:destinationModel, error:nil)
        manager = NSMigrationManager.alloc.initWithSourceModel(sourceModel, destinationModel:destinationModel)
        success = manager.migrateStoreFromURL(nil,
                                         type:NSInMemoryStoreType,
                                     options:nil,
                            withMappingModel:mappingModel,
                            toDestinationURL:nil,
                             destinationType:NSInMemoryStoreType,
                          destinationOptions:nil,
                                       error:nil)
        if success
          # TODO an actual on-disk store should then be replaced on disk
        else
          raise 'Oh noes!'
        end
      else
        raise 'Oh noes!'
      end
    end

    # Schema definition

    # TODO the use should be able to specify the code for the actual migration here.
    # See: https://github.com/mdiep/CoreDataInCode/blob/master/Source/Models/RBObjectModel_v003.m#L92
    def mappingModel
      nil
    end

    def registerEntity(entity_description)
      self.entities = entities.arrayByAddingObject(entity_description)
    end

    # This is used in a dump by Schema#to_ruby.
    def entity
      e = EntityDescription.new
      yield e if block_given?
      registerEntity(e)
    end

    def toRuby
%{
Schema.defineVersion('#{NSBundle.mainBundle.infoDictionary['CFBundleVersion']}') do |s|
#{entities.map { |e| entityToRuby(e) }.join}
end
}
    end

    private

    # TODO .select { |p| p.is_a?(AttributeDescription) } is needed because we don't serialize relationships yet
    def entityToRuby(entity)
%{
  s.entity do |e|
    e.name = '#{entity.name}'
    e.managedObjectClassName = '#{entity.managedObjectClassName}'
#{entity.properties.select { |p| p.is_a?(AttributeDescription) }.map { |p| propertyToRuby(p) }.join("\n")}
  end
}
    end

    def propertyToRuby(property)
      reflection = property.attributeReflection
      %{    e.property #{reflection[:name].inspect}, #{reflection[:type]}, #{reflection[:options].inspect}}
    end

  end

end
