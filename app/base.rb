class Base < NSManagedObjectModel
  class << self

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
