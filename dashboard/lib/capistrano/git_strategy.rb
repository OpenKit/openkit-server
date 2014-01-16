# Patch the git:release task to enable archiving of a repo subdirectory
require 'capistrano/git'

module GitStrategy
  include ::Capistrano::Git::DefaultStrategy
  def release
    git :archive, archive_argument, '| tar -x -C', release_path
  end

  private
  def archive_argument
    x = fetch(:branch) || "master"
    if y = fetch(:subdir)
      x = "#{x}:#{y}"
    end
    x
  end
end
