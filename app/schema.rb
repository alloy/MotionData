module MotionData

  class EntityDescription < NSEntityDescription
    def addProperty(name, type, options={})
      ad = AttributeDescription.withReflection(:name => name, :type => type, :options => options)
      self.properties = properties.arrayByAddingObject(ad)
    end
  end

  class AttributeDescription < NSAttributeDescription
    # This is stored mainly so it can easily be dumped by Schema#to_ruby.
    attr_accessor :attributeReflection

    def self.withReflection(reflection)
      ad = new
      ad.attributeReflection = reflection
      ad.name                = reflection[:name]
      ad.optional            = !reflection[:options][:required]

      type = reflection[:type]
      ad.attributeType = if type == String then NSStringAttributeType
                         elsif type == CoreTypes::Boolean then NSBooleanAttributeType
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

    def registerEntity(entity_description)
      self.entities = entities.arrayByAddingObject(entity_description)
    end

    # This is used in a dump by Schema#to_ruby.
    def addEntity
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

    def entityToRuby(entity)
%{
  s.addEntity do |e|
    e.name = '#{entity.name}'
    e.managedObjectClassName = '#{entity.managedObjectClassName}'
#{entity.properties.map { |p| propertyToRuby(p) }.join("\n")}
  end
}
    end

    def propertyToRuby(property)
      reflection = property.attributeReflection
      %{    e.addProperty #{reflection[:name].inspect}, #{reflection[:type]}, #{reflection[:options].inspect}}
    end
  end

end
