class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)

    #p Schema.instance.entities.map(&:description)

    puts
    puts Schema.instance.to_ruby
    puts

    true
  end
end
