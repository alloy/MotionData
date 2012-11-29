class Author < MotionData::ManagedObject
end

class Article < MotionData::ManagedObject
end

class Author
  hasMany :articles, :destinationEntity => Article.entityDescription, :inverse => :author

  property :name, String, :required => true
  property :fee, Float
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
