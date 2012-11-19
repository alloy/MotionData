# -*- encoding: utf-8 -*-
require File.expand_path('../lib/motion_data/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["alloy"]
  gem.email         = [""]
  gem.description   = "MotionData for RubyMotion"
  gem.summary       = "MotionData for RubyMotion"
  gem.homepage      = "http://github.com/alloy/MotionData"

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "motion_data"
  gem.require_paths = ["lib"]
  gem.version       = MotionData::VERSION
end
