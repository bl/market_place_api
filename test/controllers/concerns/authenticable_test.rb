require 'test_helper'

class AuthenticableTest < ActionController::TestCase
  include Authenticable

  def setup
    @user = users(:one)
    request.headers['Authorization'] = @user.auth_token
  end

  test "returns the user from the authroization header" do
    assert_equal @user, current_user
  end

  test "render a json error message" do

  end

end
