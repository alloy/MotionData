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
        Scope::Model.alloc.initWithTarget(self)
      end

      def where(conditions)
        all.where(conditions)
      end

      # TODO copy to subclasses of abstract models
      def scopes
        @scopes ||= {}
      end

      # Adds a named scope to the class.
      def scope(name, scope)
        scopes[name] = scope
      end

      # Returns a scope that matches the method name if one exists.
      #
      # TODO Until RubyMotion allows the use of define_method, this is the best
      # we can do.
      def method_missing(method, *args, &block)
        if scope = scopes[method]
          scope
        else
          super
        end
      end
    end

    def writeAttribute(key, value)
      key = key.to_s
      willChangeValueForKey(key)
      setPrimitiveValue(value, forKey:key)
      didChangeValueForKey(key)
    end

  end

end
