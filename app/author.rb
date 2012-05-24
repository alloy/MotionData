class Author < Base
  has_many :articles, :class => Article

  property :name, String, :required => true
end
