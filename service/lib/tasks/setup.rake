namespace :setup do

  desc "Start mysql server and redis"
  task :prereqs do
    puts "NOTE: This task assumes you have installed redis and mysql via homebrew.\n\n"
    test_running =-> (name, cmd) do
      if system "ps -ef | grep #{name} | grep -v grep > /dev/null"
        puts "Skipping #{name}, already running."
      else
        print "Starting #{name} in background..."
        if system "#{cmd} 1>/dev/null 2>&1"
          puts HighLine.color "succeeded.", :green
        else
          puts HighLine.color "FAILED!", :red
          puts "\tTry running the command:\n\t$ #{cmd}"
        end
      end
    end

    test_running.('mysqld', 'mysql.server start')
    test_running.('redis-server', 'redis-server /usr/local/etc/redis.conf --daemonize yes')
  end


  desc "Creates a test app, for use with api_tester.rb"
  task :api_test_app => :environment do
    Developer.destroy_all(email: 'end_to_end@example.com')
    dev = Developer.create!(email: 'end_to_end@example.com', name: 'Test Developer', password: 'password', password_confirmation: 'password')
    app = dev.apps.create!(name: 'End to end test')
    app.send(:remove_secret_from_redis)
    app.update_attribute(:app_key, 'end_to_end_test')
    app.update_attribute(:secret_key, 'TL5GGqzfItqZErcibsoYrNAuj7K33KpeWUEAYyyU')
    app.send(:store_secret_in_redis)
    puts "Created:\n\tkey: #{app.app_key}\n\tsecret: #{app.secret_key}"
  end
end
