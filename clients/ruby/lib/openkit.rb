# API
# ===
#
# Set credentials:
#   OpenKit::Config.app_key = "<your-app-key>"
#   OpenKit::Config.secret_key = "<your-secret-key>"
#
# Get:
#   response = OpenKit::Get.from('/v1/leaderboards')
#
# Post:
#   response = OpenKit::Post.to('/v1/users', {:nick => 'lou'})
#
# Put:
#   response = OpenKit::Put.to('/v1/users/:id', {:nick => 'lou z'})
#
# Multipart Post:
#   upload = Upload.new('score[meta_doc]', 'path-to-file')    # The first param is the form param name to use for the file
#   response = OpenKit::PostMultipart.to('/v1/scores', {:score => {:value => 100}}, upload
#

module OpenKit
  class Config
    class << self
      attr_accessor :app_key, :secret_key
      attr_accessor :skip_https
    end
  end
end

require_relative 'openkit/get.rb'
require_relative 'openkit/put.rb'
require_relative 'openkit/delete.rb'
require_relative 'openkit/post.rb'
require_relative 'openkit/post_multipart.rb'
