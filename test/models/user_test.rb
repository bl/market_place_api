require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # pre save/creation user (ie what you'd receive from a post call)
  def setup
    @user = User.new(email: "test@email.com",
                     password:               "12345678",
                     password_confirmation:  "12345678" )
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

  test "should have authentication token" do
  end
end
