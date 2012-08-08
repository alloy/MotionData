module MotionData

  module CoreTypes
    class Boolean
    end

    class Integer16
    end

    class Transformable
    end
  end

  class ManagedObject < NSManagedObject
    include CoreTypes

    class << self

      def new(properties = nil)
        newInContext(Context.current, properties)
      end

      def newInContext(context, properties = nil)
        entity = alloc.initWithEntity(entityDescription, insertIntoManagedObjectContext:context)
        properties.each { |k, v| entity.send("#{k}=", v) } if properties
        entity
      end

      def inherited(klass)
        MotionData::Schema.current.registerEntity(klass.entityDescription)
      end

      def entityDescription
        @entityDescription ||= EntityDescription.new.tap do |ed|
          ed.name = ed.managedObjectClassName = self.name
        end
      end

      def hasOne(name, options = {})
        #puts "#{self.name} has one `#{name}' (#{options.inspect})"
        entityDescription.hasOne(name, options)
      end

      def hasMany(name, options = {})
        #puts "#{self.name} has many `#{name}' (#{options.inspect})"
        entityDescription.hasMany(name, options)
      end

      def property(name, type, options = {})
        entityDescription.property(name, type, options)
      end

      # Finders

      def all
        scope = NSFetchRequest.new
        scope.entity = entityDescription
        # Encueing the fetch like this ensures other transactions on the context
        # have been run.
        #
        # This is what MagicalRecord does too.
        Context.current.perform do
          Context.current.executeFetchRequest(scope, error:nil)
          # TODO handleError(error) unless results
        end
      end
    end
  end

end
