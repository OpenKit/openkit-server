module PaperclipHelper
  class << self
    def uri_for(obj, base_uri)
      if Paperclip::Attachment.default_options[:url] == ':s3_domain_url'
        obj.url
      else
        base_uri + obj.url
      end
    end
  end
end
