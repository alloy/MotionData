class Author < MotionData::Base
  hasMany :articles, :class => 'Article'

  property :name, String, :required => true
end
