module UnicornHelper
  # Putting a within block here doesn't work; I'm not sure why.
  # Using an old-fashioned cd in the execute line.
  def clean_start(rails_env)
    execute "cd #{current_path}; bundle exec unicorn_rails -c config/unicorn.conf.rb -D -E #{rails_env}"
  end

  def file_exists?(f)
    test("[ -e #{f} ]")
  end

  def contents_of_file(f)
    capture :cat, f
  end

  def kill(pid)
    begin
      execute :kill, "-s QUIT", pid
      info "Sent QUIT"
    rescue => e
      error "Something went wrong: #{e}"
    end
  end
end

