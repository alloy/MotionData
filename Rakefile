$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'MotionData'
  app.files = %w{
    lib/motion_data/schema.rb
    lib/motion_data/store_coordinator.rb
    lib/motion_data/context.rb
    lib/motion_data/predicate.rb
    lib/motion_data/managed_object.rb
    lib/motion_data/scope.rb

    app/test_models.rb
    app/app_delegate.rb
  }
  app.frameworks += %w{ CoreData }

  app.vendor_project('vendor/motion_data/ext', :static)
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
