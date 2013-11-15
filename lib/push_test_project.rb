# API
# ---
#   project = PushTestProject.new('com.whatever.foo')
#   if !project.construct
#     puts "Could not create zip of project.  Please contact lou@openkit.io"
#   else
#     puts "Project is at: #{project.path_to_zip}"
#   end
#
require 'mustache'

class PushTestProject
  attr_accessor :path_to_zip

  def initialize(bundle_identifier)
    @bundle_identifier = bundle_identifier
  end

  def construct
    success = false
    Dir.mktmpdir do |dir|    # automatically removed
      begin
        FileUtils.cp_r(Rails.root.join('files', 'OKPushTest'), dir)
        d1             = Pathname.new(dir).join('OKPushTest')
        d2             = d1.join('OKPushTest')
        plist_template = d2.join('Info-Template.plist')
        plist_output   = d2.join('OKPushTest-Info.plist')
        plist_template_contents = File.read(plist_template)

        File.open(plist_output, 'w') do |f|
          f.print Mustache.render(plist_template_contents, :bundle_id => @bundle_identifier)
        end
        FileUtils.rm(plist_template)

        self.path_to_zip = "#{Dir.mktmpdir}/OKPushTest.zip"      # new dir to persist
        success = system("cd #{dir}; zip -r #{path_to_zip} ./")  # nice and portable
      rescue
      end
    end
    success
  end
end
