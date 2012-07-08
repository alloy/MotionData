module MotionData

  module CoreTypes
    class Boolean
    end
  end

  class ManagedObject < NSManagedObject
    include CoreTypes

    class << self

      def new(properties = nil)
        #context = Thread.current[:localContext] || NSManagedObjectContext.contextForCurrentThread
        newInContext(Context.default, properties)
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

      def belongsTo(name, options = {})
        #puts "#{self.name} belongs to `#{name}' (#{options.inspect})"
      end

      def hasMany(name, options = {})
        #puts "#{self.name} has many `#{name}' (#{options.inspect})"
      end

      def property(name, type, options = {})
        entityDescription.property(name, type, options)
      end

      # Finders

      def all
        scope = NSFetchRequest.new
        scope.entity = entityDescription
        results = nil
        # Encueing the fetch like this ensures other transactions on the context
        # have been run.
        #
        # This is what MagicalRecord does too.
        Context.default.performBlockAndWait(lambda do
          results = Context.default.executeFetchRequest(scope, error:nil)
          # TODO handleError(error) unless results
        end)
        results
      end
    end
  end

end
