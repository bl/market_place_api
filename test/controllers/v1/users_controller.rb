class V1::UsersControllerTest < ActionController::TestCase

  def setup
    @user = users(:one)
    # set header to include api version 1 request
    api_version = "application/vnd.marketplace.v1"
    request.headers['Accept'] = api_version
  end

  # GET

  test "returns information about a reporter on a hash" do
    get :show, id: @user, format: :json
    user_response = JSON.parse response.body, symbolize_names: true
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
    user_response = JSON.parse response.body, symbolize_names: true
    assert_not_nil user_response[:errors]
    user_errors = user_response[:errors]
    assert_match /is invalid/, user_errors[:email].to_s
    assert_response 422
  end

  test "renders json errors on invalid attributes" do
    invalid_user_attributes = { password:               "foobar",
                                password_confirmation:  "foobar" }
    post :create, user: invalid_user_attributes, format: :json
    user_response = JSON.parse response.body, symbolize_names: true
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
    user_response = JSON.parse response.body, symbolize_names: true
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
    user_response = JSON.parse response.body, symbolize_names: true
    assert_not_nil user_response[:errors]
    user_errors = user_response[:errors]
    assert_match /doesn't match Password/, user_errors[:password_confirmation].to_s
    assert_response 422
  end

  # UPDATE
  
  test "returns information about valid updated user" do
    update_user = { email: "new@example.com" }
    patch :update, { id: @user.id, user: update_user } , format: :json
    user_response = JSON.parse response.body, symbolize_names: true
    assert_not_nil user_response[:email]
    assert_equal "new@example.com", user_response[:email].to_s

    assert_response 200
  end

  test "returns json errors on invalid email update attempt" do
    update_user = { email: "invalid.com" }
    patch :update, { id: @user.id, user: update_user }, format: :json
    user_response = JSON.parse response.body, symbolize_names: true
    assert_not_nil user_response[:errors]
    user_errors = user_response[:errors]
    assert_match /is invalid/, user_errors[:email].to_s

    assert_response 422
  end

  test "returns json errors on invalid user id update attempt" do
    update_user = { email: "test@valid.com" }
    patch :update, { id: -1, user: update_user }, format: :json
    user_response = JSON.parse response.body, symbolize_names: true
    assert_not_nil user_response[:errors]
    assert_match /not found/, user_response[:errors].to_s

    assert_response 422
  end

  # REMOVE
  

end
