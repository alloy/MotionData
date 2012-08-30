# An experiment in using Core Data in a Ruby-ish way

This uses a DSL which is inspired by [DataMapper](http://datamapper.org), but
also [ActiveRecord](http://api.rubyonrails.org/classes/ActiveRecord/Base.html).
In addition, many of its Core Date related design principles are based on
[MagicalRecord](https://github.com/magicalpanda/MagicalRecord).

### Schema

The following models define a schema that is immediatly available during development:

```ruby
class Author < MotionData::ManagedObject
  hasMany :articles, :class => 'Article', :inverse => :author

  property :name, String, :required => true
end

class Article < MotionData::ManagedObject
  belongsTo :author, :class => 'Author', :inverse => :articles

  property :title,     String,  :required => true
  property :body,      String,  :required => true
  property :published, Boolean, :default  => false
end
```

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


### Dynamic scopes

MotionData provides ‘finder scopes’, which are conceptually the same as those
in ActiveRecord.

For instance, to select a subset of an entity’s to-many association:

```ruby
author.articles.where(:published => true)
author.articles.where(:published => true).sortBy(:title)
```

Or for predicates that are more elaborate than simple `AND` condtitions, you
can use a predicate builder proxy:

```ruby
author.articles.where(value(:body) != nil).and(value(:body) != nil)
```

Finally, in case you need to create a typical `NSPredicate`, you can do that
too and pass the instance to `where`, or create one with `where`:

```ruby
author.articles.where('body != %@ AND published == %@', nil, true)
```


### Named scopes

The query builder methods that can be found in the ‘dynamic scopes’ section,
can also be ‘saved’ on the model:

```ruby
class Article
  scope :published, where(:published => true)
  scope :valid, where(value(:body) != nil)
end
```

This makes these scopes available to query _all_ of a model’s entities:

```ruby
Article.published.valid
```

Or on a to-many association:

```ruby
author.articles.published.valid
```


[1]: https://github.com/mdiep/CoreDataInCode
