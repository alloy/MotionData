The following models define the schema that is immediatly available during development:

```ruby
class Author < Base
  has_many :articles, :class => 'Article'

  property :name, String, :required => true
end

class Article < Base
  belongs_to :author, :class => 'Author'

  property :title,     String,  :required => true
  property :body,      String,  :required => true
  property :published, Boolean, :default  => false
end
```

_NOTE the association macros don't actually do anything yet._

The `Schema` instance can dump this definition, which looks like:

```ruby
Schema.define_version('1.0') do |s|

  s.add_entity do |e|
    e.name = 'Article'
    e.managedObjectClassName = 'Article'
    e.add_property :published, Boolean, {:default=>false}
    e.add_property :title, String, {:required=>true}
    e.add_property :body, String, {:required=>true}
  end

  s.add_entity do |e|
    e.name = 'Author'
    e.managedObjectClassName = 'Author'
    e.add_property :name, String, {:required=>true}
  end

end
```

As you can see it has a version, this is the app’s release version. These dumps
would be created on each new release of the app and would then allow for easy
migrations with code that can be found in @mdiep’s [CoreDataInCode][1] example.

[1]: https://github.com/mdiep/CoreDataInCode
