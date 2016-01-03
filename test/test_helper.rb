ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

# Add more helper methods to be used by all tests here...
class ActiveSupport::TestCase
  fixtures :all

  def api_header(version = 1)
    api_version = "application/vnd.marketplace.v#{version}"
    request.headers['Accept'] = api_version
  end

  def api_response_format(format = Mime::JSON)
    request.headers['Accept'] = "#{request.headers['Accept']},#{format}"
    request.headers['Content-Type'] = format.to_s
  end

  def include_default_accept_headers
    api_header
    api_response_format
  end
end
