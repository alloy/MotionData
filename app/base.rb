class Base < NSManagedObject
  class << self

    def inherited(klass)
      Schema.instance.register_entity(klass.entity_description)
    end

    def entity_description
      @entity_description ||= NSEntityDescription.new.tap do |ed|
        ed.name = ed.managedObjectClassName = self.name
      end
    end

    def belongs_to(name, options = {})
      puts "#{self.name} belongs to `#{name}' (#{options.inspect})"
    end

    def has_many(name, options = {})
      puts "#{self.name} has many `#{name}' (#{options.inspect})"
    end

    def property(name, type, options = {})
      puts "#{self.name}##{name} has type `#{type.name}' (#{options.inspect})"
    end

  end
end

class Boolean
end
