namespace :setup do

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
