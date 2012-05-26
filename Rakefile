$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'

require 'rubygems'
require 'motion-cocoapods'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'MotionData'
  app.files = %w{ app/schema.rb app/managed_object.rb app/article.rb app/author.rb app/app_delegate.rb }
  app.frameworks += %w{ CoreData }

  app.pods do
    dependency 'MagicalRecord', '~> 2.0.0'
  end
end

task 'spec' do
  # This addition to the 'spec' task will close the simulator after tests run
  # if there are no errors
  sh "osascript -e 'tell application \"iphone simulator\" to quit'"
end
