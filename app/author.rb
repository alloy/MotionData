class Author < MotionData::ManagedObject
  #hasMany :articles, :class => 'Article'

  property :name, String, :required => true
end
