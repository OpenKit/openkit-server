require 'ok_redis'
require 'paperclip_helper.rb'
require 'two_legged_oauth'
require 'feature_array.rb'
require 'apple_push/apple_push.rb'
require 'push_test_project.rb'
require 'push_queue.rb'

if OKConfig[:s3_attachment_bucket]
  Paperclip::Attachment.default_options[:url] = ':s3_domain_url'
  Paperclip::Attachment.default_options[:path] = '/:class/:attachment/:id_partition/:style/:filename'
end
