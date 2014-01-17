module UnicornHelper
  # Putting a within block here doesn't work; I'm not sure why.
  # Using an old-fashioned cd in the execute line.
  def clean_start(rails_env)
    execute "cd #{current_path}; bundle exec unicorn_rails -c config/unicorn.conf.rb -D -E #{rails_env}"
  end

  def file_exists?(f)
    test("[ -e #{f} ]")
  end

  def contents_of(file)
    return nil unless file_exists?(file)
    capture :cat, file
  end

  def kill(pid, signal)
    begin
      execute :kill, "-s #{signal}", pid
      info "Sent #{signal}"
    rescue => e
      error "Something went wrong: #{e}"
    end
  end
end

