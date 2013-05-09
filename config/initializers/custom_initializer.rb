require 'random_gen'
require 'ok_redis'
require 'reaper'


module ActiveModel
  class Errors

    def merge!(errors, options={})
      fields_to_merge = if only=options[:only]
        only
      elsif except=options[:except]
        except = [except] unless except.is_a?(Array)
        except.map!(&:to_sym)
        errors.entries.map(&:first).select do |field|
          !except.include?(field.to_sym)
        end
      else
        errors.entries.map(&:first)
      end
      fields_to_merge = [fields_to_merge] unless fields_to_merge.is_a?(Array)
      fields_to_merge.map!(&:to_sym)

      errors.entries.each do |field, msg|
        add field, msg if fields_to_merge.include?(field.to_sym)
      end
    end
  end
end

Paperclip::Attachment.default_options[:url] = ':s3_domain_url'
Paperclip::Attachment.default_options[:path] = '/:class/:attachment/:id_partition/:style/:filename'

begin
  BestScore.refresh_cache_all
  BestScore1.refresh_cache_all
  BestScore7.refresh_cache_all
rescue
end
