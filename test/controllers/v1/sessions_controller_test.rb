require 'test_helper'

class V1::SessionsControllerTest < ActionController::TestCase

  def setup
    @user = users(:one)
  end

  #POST
  test "should return json errors on invalid email" do
    credentials = { email: "invalid@example.com", password: 'foobar' }
    post :create, session: credentials, format: :json 
    user_response = JSON.parse response.body, symbolize_names: true
    assert_not_nil user_response[:errors]
    user_errors = user_response[:errors]
    assert_match /Invalid email or password/, user_errors

    assert_response 422
  end

  test "should return json errors on invalid password" do
    credentials = { email: @user.email, password: 'foo' }
    post :create, session: credentials, format: :json 
    user_response = JSON.parse response.body, symbolize_names: true
    assert_not_nil user_response[:errors]
    user_errors = user_response[:errors]
    assert_match /Invalid email or password/, user_errors

    assert_response 422
  end

  test "should return user record corresponding to given credentials" do
    credentials = { email: @user.email, password: 'foobar' }
    post :create, session: credentials, format: :json 
    user_response = JSON.parse response.body, symbolize_names: true
    assert_equal @user.email,       user_response[:email]
    assert @user.authenticated? :password, credentials[:password]
    assert_equal @user.auth_token,  user_response[:auth_token]

    assert_response 200
  end
end
