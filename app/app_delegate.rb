class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)

    #p Schema.current.entities.map(&:description)

    #puts
    #puts Schema.current.to_ruby
    #puts

    # Output from Schema.current.to_ruby
    # dumped_schema = Schema.define_version('1.0') do |s|
    #   s.add_entity do |e|
    #     e.name = 'Article'
    #     e.managedObjectClassName = 'Article'
    #     e.add_property :published, Boolean, {:default=>false}
    #     e.add_property :title, String, {:required=>true}
    #     e.add_property :body, String, {:required=>true}
    #   end

    #   s.add_entity do |e|
    #     e.name = 'Author'
    #     e.managedObjectClassName = 'Author'
    #     e.add_property :name, String, {:required=>true}
    #   end
    # end
    # Dumping it again should look exactly the same.
    puts
    puts Schema.current.to_ruby
    puts

    true
  end
end
