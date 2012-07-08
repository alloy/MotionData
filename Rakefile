$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'

require 'rubygems'
require 'motion-cocoapods'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'MotionData'
  app.files = %w{
    app/schema.rb
    app/store_coordinator.rb
    app/context.rb
    app/managed_object.rb

    app/article.rb
    app/author.rb
    app/app_delegate.rb
  }
  app.frameworks += %w{ CoreData }

  app.pods do
    dependency 'CocoaLumberjack' # Used by MagicalRecord (if available) to log
    #dependency 'MagicalRecord', '~> 2.0.0'
    dependency 'MagicalRecord', :git => 'https://github.com/magicalpanda/MagicalRecord.git'
  end
end

task 'spec' do
  # This addition to the 'spec' task will close the simulator after tests run
  # if there are no errors
  sh "osascript -e 'tell application \"iphone simulator\" to quit'"
end

namespace :spec do
  desc "Auto-run specs"
  task :kick do
    sh "bundle exec kicker -c"
  end
end
