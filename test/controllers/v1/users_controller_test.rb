require 'test_helper'

class V1::UsersControllerTest < ActionController::TestCase

  def setup
    @user = FactoryGirl.create :user
    @other_user = FactoryGirl.create :user
    # set header to include api version 1 request
    api_version = "application/vnd.marketplace.v1"
    request.headers['Accept'] = api_version
  end

  # GET

  test "returns information about a reporter on a hash" do
    get :show, id: @user, format: :json
    user_response = json_response[:user]
    assert_equal @user.email, user_response[:email]
    # assert_equal 200, response.status
    assert_response 200
  end

  # POST

  test "renders json errors on invalid email" do
    invalid_user = { email: "invalid_email",
                     password:              "foobar",
                     password_confirmation: "foobar" }
    post :create, user: invalid_user, format: :json
    user_response = json_response
    assert_not_nil user_response[:errors]
    user_errors = user_response[:errors]
    assert_match /is invalid/, user_errors[:email].to_s
    assert_response 422
  end

  test "renders json errors on invalid attributes" do
    invalid_user_attributes = { password:               "foobar",
                                password_confirmation:  "foobar" }
    post :create, user: invalid_user_attributes, format: :json
    user_response = json_response
    assert_not_nil user_response[:errors]
    user_errors = user_response[:errors]
    assert_match /can't be blank/, user_errors[:email].to_s
    assert_response 422
  end

  test "renders json errors on invalid password" do
    invalid_user = { email: "email@valid.com",
             password:              "",
             password_confirmation: "foobar" }
    post :create, user: invalid_user, format: :json
    user_response = json_response
    assert_not_nil user_response[:errors]
    user_errors = user_response[:errors]
    assert_match /can't be blank/, user_errors[:password].to_s
    assert_response 422
  end

  test "renders json errors on invalid password confirmation" do
    invalid_user = { email: "email@valid.com",
             password:              "foobar",
             password_confirmation: "foobaz" }
    post :create, user: invalid_user, format: :json
    user_response = json_response
    assert_not_nil user_response[:errors]
    user_errors = user_response[:errors]
    assert_match /doesn't match Password/, user_errors[:password_confirmation].to_s
    assert_response 422
  end

  # UPDATE
  test "returns json errors when not logged in" do
    update_user = { email: "new@example.com" }
    patch :update, { id: @user, user: update_user } , format: :json
    user_response = json_response
    assert_not_nil user_response[:errors]
    assert_match /Not authenticated/, user_response[:errors].to_s

    assert_response 401
  end
  
  test "returns information about valid updated user" do
    log_in_as @user
    update_user = { email: "new@example.com" }
    patch :update, { id: @user, user: update_user } , format: :json
    user_response = json_response[:user]
    assert_not_nil user_response[:email]
    assert_equal "new@example.com", user_response[:email].to_s

    assert_response 200
  end

  test "returns json errors on invalid email update attempt" do
    log_in_as @user
    update_user = { email: "invalid.com" }
    patch :update, { id: @user, user: update_user }, format: :json
    user_response = json_response
    assert_not_nil user_response[:errors]
    user_errors = user_response[:errors]
    assert_match /is invalid/, user_errors[:email].to_s

    assert_response 422
  end

  test "returns json errors on non-logged-in user id update attempt" do
    log_in_as @user
    update_user = { email: "test@valid.com" }
    patch :update, { id: @other_user.id, user: update_user }, format: :json
    user_response = json_response
    assert_not_nil user_response[:errors]
    assert_match /Incorrect user/, user_response[:errors].to_s

    assert_response 403
  end

  test "returns json errors on invalid user id update attempt" do
    log_in_as @user
    update_user = { email: "test@valid.com" }
    patch :update, { id: -1, user: update_user }, format: :json
    user_response = json_response
    assert_not_nil user_response[:errors]
    assert_match /Incorrect user/, user_response[:errors].to_s

    assert_response 403
  end

  # REMOVE

  test "returns errors when not logged in" do
    assert_no_difference 'User.count' do
      delete :destroy, { id: @user }, format: :json
    end 
    user_response = json_response
    assert_not_nil user_response[:errors]
    user_errors = user_response[:errors]
    assert_match /Not authenticated/, user_response[:errors].to_s

    assert_response 401
  end
  
  test "returns confirmation on valid user deletion" do
    log_in_as @user
    assert_difference 'User.count', -1 do
      delete :destroy, { id: @user }, format: :json
    end 
    assert_nil User.find_by id: @user.id

    assert_response 204
  end

  test "returns errors on non-logged-in user id deletion" do
    log_in_as @user
    assert_no_difference 'User.count' do
      delete :destroy, { id: @other_user.id }, format: :json
    end 
    user_response = json_response
    assert_not_nil user_response[:errors]
    user_errors = user_response[:errors]
    assert_match /Incorrect user/, user_response[:errors].to_s

    assert_response 403
  end

  test "returns errors on invalid user id deletion" do
    log_in_as @user
    assert_no_difference 'User.count' do
      delete :destroy, { id: -1 }, format: :json
    end 
    user_response = json_response
    assert_not_nil user_response[:errors]
    user_errors = user_response[:errors]
    assert_match /Incorrect user/, user_response[:errors].to_s

    assert_response 403
  end
end
