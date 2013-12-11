require 'openkit'
gem "minitest", '~>4.7'
require 'minitest/autorun'
require 'turn'
#require 'debugger'

class ApiTest < MiniTest::Unit::TestCase
  include OpenKit::Request

  def setup
    OpenKit::Config.skip_https = true
    OpenKit::Config.app_key    = '9c7FMNznXbQC4Pr4FHi5'
    OpenKit::Config.secret_key = 'o2HdzSZg99jdmP4oi0LdiJwFPYG06gXvCGqNHeXG'
  end

  def random_alphanumeric(n)
    Array.new(n){[*'0'..'9', *'a'..'z', *'A'..'Z'].sample}.join
  end
end
