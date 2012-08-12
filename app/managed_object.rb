class Class
  def defineClassMethod(name, &block)
    # This is really only needed if/when we need to eval it in the context of
    # the instance. Until then we'll optimize by simply using the block as
    # passed by the caller and let the code there deal with it.
    #
    #ClassExt.defineRubyClassMethod(lambda { |_self| _self.instance_eval(&block) }, withSelector:name, onClass:self)
    ClassExt.defineRubyClassMethod(block, withSelector:name, onClass:self)
  end

  def defineInstanceMethod(name, &block)
    # This is really only needed if/when we need to eval it in the context of
    # the instance. Until then we'll optimize by simply using the block as
    # passed by the caller and let the code there deal with it.
    #
    #ClassExt.defineRubyInstanceMethod(lambda { |_self| _self.instance_eval(&block) }, withSelector:name, onClass:self)
    ClassExt.defineRubyInstanceMethod(block, withSelector:name, onClass:self)
  end
end

module MotionData

  module CoreTypes
    class Boolean
    end

    class Integer16
    end

    class Transformable
    end
  end

  class ManagedObject < MotionDataManagedObjectBase
    include CoreTypes

    extend Predicate::Builder::Mixin
    include Predicate::Builder::Mixin

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
          ed.name = ed.managedObjectClassName = name
        end
      end

      def hasOne(name, options = {})
        #puts "#{self.name} has one `#{name}' (#{options.inspect})"
        entityDescription.hasOne(name, options)
      end

      def hasMany(name, options = {})
        #puts "#{self.name} has many `#{name}' (#{options.inspect})"
        entityDescription.hasMany(name, options)
        defineRelationshipMethod(name)
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

      # Adds a named scope to the class and makes it available as a class
      # method named after the scope.
      def scope(name, scope)
        scopes[name] = scope
        defineNamedScopeMethod(name)
        scope
      end

      # Called from method that's dynamically added from
      # +[MotionDataManagedObjectBase defineNamedScopeMethod:]
      def scopeByName(name)
        scopes[name]
      end
    end

    # Called from method that's dynamically added from
    # +[MotionDataManagedObjectBase defineRelationshipMethod:]
    def relationshipByName(name)
      willAccessValueForKey(name)
      scope = Scope::Relationship.alloc.initWithTarget(primitiveValueForKey(name),
                                      relationshipName:name,
                                                 owner:self,
                                            ownerClass:self.class)
      didAccessValueForKey(name)
      scope
    end

    def writeAttribute(key, value)
      key = key.to_s
      willChangeValueForKey(key)
      setPrimitiveValue(value, forKey:key)
      didChangeValueForKey(key)
    end
  end

end
