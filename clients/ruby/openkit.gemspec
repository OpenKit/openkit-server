# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'openkit/version'

Gem::Specification.new do |spec|
  spec.name          = "openkit"
  spec.version       = Openkit::VERSION
  spec.authors       = ["Lou Zell"]
  spec.email         = ["lou@openkit.io"]
  spec.description   = %q{List leaderboards, post scores, etc.}
  spec.summary       = %q{Client for OpenKit's gaming backend}
  spec.homepage      = "https://github.com/OpenKit/openkit-server/tree/development/clients/ruby"
  spec.license       = "MIT"
  spec.files = %w[
    Gemfile
    LICENSE.txt
    README.md
    Rakefile
    lib/openkit.rb
    lib/openkit/request/base.rb
    lib/openkit/request/base_delegate.rb
    lib/openkit/request/delete.rb
    lib/openkit/request/get.rb
    lib/openkit/request/post.rb
    lib/openkit/request/post_multipart.rb
    lib/openkit/request/put.rb
    lib/openkit/request/upload.rb
    lib/openkit/request.rb
    lib/openkit/version.rb
    test/api/score_api_test.rb
    test/api/user_api_test.rb
    test/test_helper.rb
    openkit.gemspec
  ]
  spec.executables   = []
  spec.test_files    = spec.files.grep(%r{^(test)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler",  "~> 1.3"
  spec.add_development_dependency "rake",     "~> 10.1"
  spec.add_development_dependency "minitest", "~> 4.7"
  spec.add_development_dependency "turn",     "~> 0"

  spec.add_dependency 'multipart-post', "~> 2.0"
end
