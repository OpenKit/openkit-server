ENV["RAILS_ENV"] = "test"
require File.expand_path("../../config/environment", __FILE__)

require "rails/test_help"
require 'mocha/setup'
require 'authlogic/test_case'
include Authlogic::TestCase

Turn.config do |c|
 c.format  = :outline
 c.natural = true
end
