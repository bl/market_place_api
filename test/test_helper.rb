ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

# Add more helper methods to be used by all tests here...
class ActiveSupport::TestCase
  fixtures :all
end
