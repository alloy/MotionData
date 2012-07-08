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
        newInContext(Context.main, properties)
      end

      def newInContext(context, properties = nil)
        entity = alloc.initWithEntity(entityDescription, insertIntoManagedObjectContext:context)
        properties.each { |k, v| entity.send("#{k}=", v) } if properties
        entity
      end

      def saveInBackground(&block)
        MagicalRecord.saveInBackgroundWithBlock(lambda do |localContext|
          Thread.current[:localContext] = localContext
          block.call(localContext)
          Thread.current[:localContext] = nil
        end)
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
    end
  end

end
