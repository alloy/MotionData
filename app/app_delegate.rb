class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)

    p Schema.instance.entities.map(&:description)

    true
  end
end
