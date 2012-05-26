class Article < MotionData::ManagedObject
  belongsTo :author, :class => 'Author'

  property :title,     String,  :required => true
  property :body,      String,  :required => true
  property :published, Boolean, :default  => false
end
