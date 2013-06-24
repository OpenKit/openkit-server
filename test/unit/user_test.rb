require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    dev = Developer.create!(
      :email => 'lzell11@gmail.com',
      :name => 'Lou Zell',
      :password => 'password',
      :password_confirmation => 'password')

    app = dev.apps.new(:name => 'My App!')
    app.save

    @app_key = app.app_key
  end


  test "can create via custom_id" do
    assert_equal 0, User.count

    authorized_app = App.find_by_app_key(@app_key)
    user_params = {
      :nick => 'Foo',
      :custom_id => '123'
    }

    @user = authorized_app.find_or_create_subscribed_user(user_params)
    assert_equal 1,   User.count
    assert_equal 123, User.first.custom_id
  end

  test "should require custom_id, twitter_id, fb_id, or google_id" do
    authorized_app = App.find_by_app_key(@app_key)

    user = authorized_app.find_or_create_subscribed_user({:nick => 'Foo'})
    assert user.new_record?

    %w(fb_id twitter_id google_id custom_id).each do |service_id|
      user = authorized_app.find_or_create_subscribed_user({:nick => 'Foo', service_id => 9})
      assert !user.new_record?
    end
  end
end
