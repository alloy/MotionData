class Schema < NSManagedObjectModel
  def self.instance
    @instance ||= new
  end

  def register_entity(entity_description)
    self.entities = entities.arrayByAddingObject(entity_description)
  end

  # This is used in a dump by Schema#to_ruby.
  def add_entity
    e = NSEntityDescription.new
    yield e
    register_entity(e)
  end

  def to_ruby
%{
Schema.define_version('#{NSBundle.mainBundle.infoDictionary['CFBundleVersion']}') do |s|
#{entities.map { |e| entity_to_ruby(e) }.join}
end
}
  end

  private

  def entity_to_ruby(entity)
%{
  s.add_entity do |e|
    e.name = '#{entity.name}'
    e.managedObjectClassName = '#{entity.managedObjectClassName}'
#{entity.properties.map { |p| property_to_ruby(p) }.join("\n")}
  end
}
  end

  def property_to_ruby(property)
    reflection = property.attribute_reflection
    %{    e.add_property #{reflection[:name].inspect}, #{reflection[:type]}, #{reflection[:options].inspect}}
  end
end
