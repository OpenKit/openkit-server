# Openkit

The ruby client for OpenKit's gaming backend.

## Installation

Add this line to your application's Gemfile:

    gem 'openkit'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install openkit

## Usage

Get your app_key and secret_key from [https://developer.openkit.io](https://developer.openkit.io).

Set credentials:

	OpenKit::Config.app_key = "<your-app-key>"
	OpenKit::Config.secret_key = "<your-secret-key>"
	OpenKit::Config.skip_https = true  # required unless you're using the beta-api endpoint

Request examples:

	include OpenKit::Request
	
	# Get
	response = Get.new('/v1/leaderboards').perform
	
	# Post
	response = Post.new('/v1/users', {:nick => 'lou'}).perform
	
	# Put
	response = Put.new('/v1/users/:id', {:nick => 'lou z'}).perform
	
	# Multipart Post
	upload = Upload.new('<param-name-of-upload>', '<path-to-file>')
	req = OpenKit::PostMultipart.new('/v1/scores', {:score => {:value => 100}}, upload)
	response = req.perform
	
Parse the response:
	
	json = JSON.parse(response.body)
	
Check the response headers:
	
	puts response.code
	response.header.each { |h, v| puts "#{h}: #{v}" }


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
