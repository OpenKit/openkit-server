ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)

require "rails/test_help"
require 'mocha/setup'
require 'authlogic/test_case'
include Authlogic::TestCase

FactoryGirl.find_definitions

class ActiveSupport::TestCase
  self.use_transactional_fixtures = true
end


Turn.config do |c|
 c.format  = :outline  # :progress
end
