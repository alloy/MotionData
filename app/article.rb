class Article < MotionData::Base
  belongs_to :author, :class => 'Author'

  property :title,     String,  :required => true
  property :body,      String,  :required => true
  property :published, Boolean, :default  => false
end
