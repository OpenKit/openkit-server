require 'zeus/rails'

# Overriding the test method for a couple reason:
#
#   1. We don't want to fall back to rake if arguments are not supplied.
#      That is, 'zeus t' should run all tests without involving rake.
#
#   2. 'rails/test_help', which is required by dashboard/test/test_helper.rb,
#      eventually calls MiniTest::Unit.autorun.  The default Zeus test
#      implementation uses Zeus::M.run to explicitly run tests.  This led to
#      tests running twice.
#
class CustomPlan < Zeus::Rails

  # See lib/zeus/rails.rb in the Zeus gem to see default behavior.
  def test(argv=ARGV)
    if argv.empty?
      Dir[Rails.root.join("test/**/*.rb")].each {|f| require f}
    else
      argv.each {|f| require f}
    end
  end

end

Zeus.plan = CustomPlan.new
