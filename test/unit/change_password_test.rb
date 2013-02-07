require File.expand_path(File.join(File.dirname(__FILE__), '..', 'test_helper'))
class ChangePasswordTest < ActiveSupport::TestCase
  def setup
    @model = ChangePassword.new
  end

  # Test whether Change Password follows the ActiveRecord API.
  include ActiveModel::Lint::Tests
end
