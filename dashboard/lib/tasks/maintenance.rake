namespace :maintenance do
  desc "De-dups scores"
  task :dedup => :environment do
    STDOUT.print "This modifies the DB, are you sure? (y/n) "
    if STDIN.gets.chomp == "y"
      ActiveRecord::Base.logger = Logger.new(STDOUT)
      Leaderboard.all.each do |leaderboard|
        op = (leaderboard.sort_type == "HighValue") ? '>' : '<'
        scores = leaderboard.scores
        extremes = {}
        scores.each do |score|
          if extremes[score.user_id].nil?
            extremes[score.user_id] = score
          elsif score.value.send(op, extremes[score.user_id].value)
            extremes[score.user_id].destroy
            extremes[score.user_id] = score
          else
            score.destroy
          end
        end
      end
    end
  end

  #
  # Syntax:
  #   $ rake maintenance:reload_db["my_db.sql"]
  #
  desc "Reload local DB, optionally with a .sql file to populate db with"
  task :reload_db, [:sql_file] do |t, args|
    db_name = "leaderboard_dev"
    STDOUT.print "This modifies the DB, are you sure? (y/n) "
    if STDIN.gets.chomp == "y"
      puts "Dropping #{db_name}..."
      system "mysqladmin -u root drop #{db_name}"

      puts "\nCreating #{db_name}..."
      system "mysqladmin -u root create #{db_name}"

      if args.sql_file
        puts "\nImporting from #{args.sql_file}..."
        system("mysql -u root #{db_name} < #{args.sql_file}")
      end
    end
    puts "Done."
  end

  desc "Prune users"
  task :prune_users => :environment do
    STDOUT.print "This modifies the DB, are you sure? (y/n) "
    if STDIN.gets.chomp == "y"
      ActiveRecord::Base.logger = Logger.new(STDOUT)
      User.unreferenced.destroy_all
    end
  end


  desc "Move assets to S3"
  task :move_ass, [:bucket] do |t, args|
    key, secret = File.read(File.join(Dir.home, '.awssecret')).split("\n")
    storage = Fog::Storage.new(:provider => 'AWS', :aws_access_key_id => key, :aws_secret_access_key => secret, :region => 'us-west-2')
    ok_up = storage.directories.new(:key => args.bucket.to_s)

    attachment_files = nil
    Dir.chdir("public/system") do
      attachment_files = %x(find * -type f).split("\n")
      attachment_files.each do |f|
        foo = ok_up.files.create(:key => f, :body => File.open(f), :public => true)
      end
    end
  end


  desc "Populate player sets"
  task :fill_player_sets => :environment do
    STDOUT.print "You are in the #{Rails.env.upcase} environment.  Are you sure about this? (y/n) "
    if STDIN.gets.chomp == "y"
      Leaderboard.all.each do |leaderboard|
        STDOUT.print "Populating player set for leaderboard #{leaderboard.id}..."
        Score.where(:leaderboard_id => leaderboard.id).group(:user_id).each do |score|
          k = "leaderboard:#{leaderboard.id}:players"
          if !score.user_id.blank? && score.user_id != 0
            OKRedis.connection.sadd(k, score.user_id)
          end
        end
        STDOUT.print "done.\n"
      end
    end
  end

  desc "Populate secret keys"
  task :pop_secret => :environment do
    STDOUT.print "You are in the #{Rails.env.upcase} environment.  Are you sure about this? (y/n) "
    if STDIN.gets.chomp == "y"
      App.all.each do |app|
        app.send :store_secret_in_redis
      end
    end
  end

end
