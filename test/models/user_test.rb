require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # pre save/creation user (ie what you'd receive from a post call)
  def setup
    @user = User.new(email: "test@email.com",
                     password:               "12345678",
                     password_confirmation:  "12345678" )
    @other_user = User.new
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "email should be present" do
    @user.email = "  "
    assert_not @user.valid?
  end

  test "email should be case in-sensitive" do
    @user.email = "ExAMPLE@EmaIL.com"
    @user.save
    duplicate_user = @user.dup
    duplicate_user.email.downcase!
    assert_not duplicate_user.valid?
  end

  test "email should be lowercase on save" do
    @user.email = "ExAMPLE@EmaIL.com"
    @user.save
    assert @user.valid?
    @user.reload.email == "exampale@email.com"
  end

  test "email should be unique" do
    @user.save
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    duplicate_user.save
    assert_not duplicate_user.valid?
  end

  test "email should not accept invalid emails" do
    invalid_emails = %w[@gmail.com test.com @email.com grep@email chris.james@james]
    invalid_emails.each do |email|
      @user.email = email;
      assert_not @user.valid?
    end
  end

  test "email should accept valid emails" do
    valid_emails = %w[test@email.com a.b.@email.com email@test.co.uk]
    valid_emails.each do |email|
      @user.email = email;
      assert @user.valid?
    end
  end

  test "password should be present" do
    @user.password = " "
    @user.password_confirmation = ""
    assert_not @user.valid?
  end

  test "valid password should be authenticated" do
    assert @user.authenticated? :password, "12345678"
    assert_not @user.authenticated? :password, "123456789"
    @user.password_digest = nil
    assert_not @user.authenticated? :password, "12345678"

    # verify User.digest mimicks internal has_secure_password
    @user.password_digest = User.digest("12345678")
    assert @user.authenticated? :password, "12345678"
  end

  test "should accept valid authentication token" do
    @user.auth_token = :auth_token
    assert @user.valid?
  end

  test "auth_token should be unique" do
    user_params = { email: "firstuser@example.com", 
                   password: "foobar" }
    first_user = User.create user_params
    duplicate_user = first_user.dup
    duplicate_user.email = "unique@email.com"
    assert_not duplicate_user.valid?
    duplicate_user.auth_token = User.new_token
    assert duplicate_user.valid?
  end

  test "auth_token should be generated on create" do
    new_user = User.create email: "newuser@email.com", password: "foobar"
    assert new_user.valid?
    assert_not_nil new_user.auth_token
  end

  # TODO: look into reliable method of replicating token conflicts
  test "auth_token should be regenerated on conflict" do
    user_params = { email: "firstuser@example.com", 
                   password: "foobar" }
    first_user = User.create user_params
    assert first_user.valid?
    user_params[:email] = "seconduser@example.com"
    second_user = User.create user_params
    assert second_user.valid?
    assert_not_equal first_user.auth_token, second_user.auth_token
  end
end
