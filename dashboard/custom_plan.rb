require 'zeus/rails'

class CustomPlan < Zeus::Rails
  # Overriding the test plan to avoid falling back to rake.
  # See lib/zeus/rails.rb in the Zeus gem to see default behavior.
  def test(argv=ARGV)
    if argv.empty?
      Zeus::M.run(["test/**/*_test.rb"])
    else
      Zeus::M.run(ARGV)
    end
  end
end

Zeus.plan = CustomPlan.new
