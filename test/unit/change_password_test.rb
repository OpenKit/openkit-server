require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))

class ChangePasswordTest < ActiveSupport::TestCase
  setup :activate_authlogic

  def setup
    @dev = Developer.new(:email => "foo@example.com", :password => "oldpassword", :password_confirmation => "oldpassword")
    @dev.save!
    @model = ChangePassword.new(current_password: "oldpassword",
                                new_password: "newpassword",
                                new_password_confirmation: "newpassword",
                                developer: @dev)
    @model.save
  end

  test "that we were able to update the password" do
    assert @model.errors.empty?
  end

  test "that we cannot login with the old password" do
    session = DeveloperSession.new(:email => @dev.email, :password => "oldpassword")
    assert !session.valid?, "Old password still works!"
  end

  test "that we can login with new password" do
    session = DeveloperSession.new(:email => @dev.email, :password => "newpassword")
    assert session.valid?
  end

  # We're testing whether ChangePassword follows the ActiveRecord API by
  # setting up a @model and including the ActiveModel::Lint::Tests
  include ActiveModel::Lint::Tests
end
