require 'test_helper'

class V1::SessionsControllerTest < ActionController::TestCase

  def setup
    @user = FactoryGirl.create :user
  end

  #POST

  test "should return json errors on invalid email" do
    credentials = { email: "invalid@example.com", password: 'foobar' }
    post :create, session: credentials, format: :json 
    user_response = json_response
    assert_not_nil user_response[:errors]
    user_errors = user_response[:errors]
    assert_match /Invalid email or password/, user_errors

    assert_response 422
  end

  test "should return json errors on invalid password" do
    credentials = { email: @user.email, password: 'foo' }
    post :create, session: credentials, format: :json 
    user_response = json_response
    assert_not_nil user_response[:errors]
    user_errors = user_response[:errors]
    assert_match /Invalid email or password/, user_errors

    assert_response 422
  end

  test "should return user record corresponding to given credentials" do
    credentials = { email: @user.email, password: 'foobar' }
    post :create, session: credentials, format: :json 
    user_response = json_response[:user]
    assert_equal @user.email,       user_response[:email]
    assert @user.authenticated? :password, credentials[:password]
    assert_equal @user.reload.auth_token,  user_response[:auth_token]

    assert_response 200
  end

  # DELETE
  
  test "should change user token on valid destroy" do
    old_token = @user.auth_token
    delete :destroy, id: @user.auth_token, format: :json
    # empty body on valid destroy
    assert response.body.empty?
    assert_not_equal old_token, @user.reload.auth_token

    assert_response 204
  end

  test "should return json errors on invalid token" do
    old_token = @user.auth_token
    delete :destroy, id: "invalid_token", format: :json
    user_response = json_response
    assert_not_nil user_response[:errors]
    assert_equal old_token, @user.reload.auth_token
    assert_match /not found/, user_response[:errors]

    assert_response 422
  end
end
