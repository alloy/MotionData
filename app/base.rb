module MotionData

  module CoreTypes
    class Boolean
    end
  end

  class Base < NSManagedObject
    include CoreTypes

    class << self

      def inherited(klass)
        Schema.current.register_entity(klass.entity_description)
      end

      def entity_description
        @entity_description ||= EntityDescription.new.tap do |ed|
          ed.name = ed.managedObjectClassName = self.name
        end
      end

      def belongs_to(name, options = {})
        #puts "#{self.name} belongs to `#{name}' (#{options.inspect})"
      end

      def has_many(name, options = {})
        #puts "#{self.name} has many `#{name}' (#{options.inspect})"
      end

      def property(name, type, options = {})
        #puts "#{self.name}##{name} has type `#{type.name}' (#{options.inspect})"
        entity_description.add_property(name, type, options)
      end
    end
  end


  class EntityDescription < NSEntityDescription
    def add_property(name, type, options)
      ad = AttributeDescription.with_reflection(:name => name, :type => type, :options => options)
      self.properties = properties.arrayByAddingObject(ad)
    end
  end

  class AttributeDescription < NSAttributeDescription
    # This is stored mainly so it can easily be dumped by Schema#to_ruby.
    attr_accessor :attribute_reflection

    def self.with_reflection(reflection)
      ad = new
      ad.attribute_reflection = reflection
      ad.name                 = reflection[:name]
      ad.optional             = !reflection[:options][:required]
      ad.attributeType        = case reflection[:type]
                                when String  then NSStringAttributeType
                                when CoreTypes::Boolean then NSBooleanAttributeType
                                # etc
                                else
                                  # Transient types?
                                  NSUndefinedAttributeType
                                end
      ad
    end
  end

end
