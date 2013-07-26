class Author < MotionData::ManagedObject
end

class Article < MotionData::ManagedObject
end

class LastNameTransformer < NSValueTransformer
   def self.allowsReverseTransformation
    true
  end

  def self.transformedValueClass
    NSString.class
  end

  def transformedValue(value)
     "prefix.#{value}".dataUsingEncoding NSUTF8StringEncoding
  end

  def reverseTransformedValue(value)
    NSString.stringWithUTF8String(value.bytes).sub /prefix/, ''
  end
end

class Author
  hasMany :articles, :destinationEntity => Article.entityDescription, :inverse => :author

  property :name, String, :required => true
  property :fee, Float
  property :last_name, Transformable, :transformer => LastNameTransformer
end

class Article
  hasOne :author, :destinationEntity => Author.entityDescription, :inverse => :articles

  property :title,     String,  :required => true
  property :body,      String,  :required => true
  property :published, Boolean, :default  => false
  property :publishedAt, Time, :default  => false
  property :length, Integer32

  scope :published, where(:published => true)
  scope :withTitle, where( value(:title) != nil ).sortBy(:title, ascending:false)
end
