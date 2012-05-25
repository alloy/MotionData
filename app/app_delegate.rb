class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)

    puts
    puts MotionData::Schema.current.toRuby
    puts

    true
  end
end
