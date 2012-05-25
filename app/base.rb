module MotionData

  module CoreTypes
    class Boolean
    end
  end

  class Base < NSManagedObject
    include CoreTypes

    class << self

      def newInManagedObjectContext context
        alloc.initWithEntity(entityDescription,
                             insertIntoManagedObjectContext: context)
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
        #puts "#{self.name}##{name} has type `#{type.name}' (#{options.inspect})"
        entityDescription.addProperty(name, type, options)
      end
    end
  end

end
