require 'colorize'

module LogInvocations
  def self.enable
    ::Rake.application.tasks.each do |t|
      t.enhance { puts "--- Capistrano Invoking: #{t.name}".magenta }
    end
  end
end
