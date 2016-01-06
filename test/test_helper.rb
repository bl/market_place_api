ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

# Add more helper methods to be used by all tests here...
class ActiveSupport::TestCase
  #fixtures :all

  include FactoryGirl::Syntax::Methods

  def get_session_for(user, options = {})
    password = options[:password] || 'foobar'
    if integration_test?
      post sessions_path, session: { email:     user.email,
                                     password:  password }
      user_attr = json_response
      user_attr[:auth_token]
    else
      user.create_auth_token!
      user.save
      user.auth_token
    end
  end

  def json_response
    JSON.parse response.body, symbolize_names: true
  end

  def log_in_as(user, options = {})
     api_authorization_header(get_session_for(user, options))
  end

  def api_authorization_header(token)
    request.headers['Authorization'] = token
  end

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

  # returns true inside of an integration test
  def integration_test?
    defined?(post_via_redirect)
  end
end
