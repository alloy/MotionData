# A naive example of a migratable RubyMotion/CoreData wrapper

This uses a DSL which is inspired by [DataMapper](http://datamapper.org), but
also [ActiveRecord](http://api.rubyonrails.org/classes/ActiveRecord/Base.html).

The following models define a schema that is immediatly available during development:

```ruby
class Author < MotionData::ManagedObject
  hasMany :articles, :class => 'Article'

  property :name, String, :required => true
end

class Article < MotionData::ManagedObject
  belongsTo :author, :class => 'Author'

  property :title,     String,  :required => true
  property :body,      String,  :required => true
  property :published, Boolean, :default  => false
end
```

_NOTE: the association macros don't actually do anything yet._

The `Schema` instance can dump this definition, which looks like:

```ruby
Schema.defineVersion('1.0') do |s|

  s.addEntity do |e|
    e.name = 'Article'
    e.managedObjectClassName = 'Article'
    e.addProperty :published, Boolean, {:default=>false}
    e.addProperty :title, String, {:required=>true}
    e.addProperty :body, String, {:required=>true}
  end

  s.addEntity do |e|
    e.name = 'Author'
    e.managedObjectClassName = 'Author'
    e.addProperty :name, String, {:required=>true}
  end

end
```

As you can see it has a version, this is the app’s release version. These dumps
would be created on each new release of the app and would then allow for easy
migrations with code that can be found in @mdiep’s [CoreDataInCode][1] example.

[1]: https://github.com/mdiep/CoreDataInCode
