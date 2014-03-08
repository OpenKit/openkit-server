## Running Locally (Instructions for OS X)

This guide assumes that you can work your way around a command line.  Specific
instructions are written for bash (the default shell on OS X), but should be
easy to apply to other shells too.

Make sure /usr/local/bin and /usr/local/sbin are in your PATH ahead of
/usr/bin.  You can check with `echo $PATH`.  If they are not, add this line to
`~/.bash_profile`:

```
export PATH="/usr/local/bin:/usr/local/sbin:~/bin:$PATH"
```

Next, install [homebrew](http://brew.sh/), if you haven't already.

Add this to `~/.bash_profile`:

	# Add gem binaries to path. (See 'brew info ruby')
	export PATH=$(brew --prefix ruby)/bin:$PATH

System dependencies:

	brew update
	brew upgrade ruby redis mysql libxml2
	gem pristine --all --only-executables

Prepare rails project:

	git clone git@github.com:OpenKit/openkit-server.git
	cd openkit-server/dashboard
	bundle install
	bin/rake setup:prereqs
	bin/rake db:setup
	bin/rails start

Testing:

	bin/rake db:test:prepare
	bin/rake test

Testing with Zeus:

	bin/rake db:test:prepare
    gem install zeus
    zeus start
    zeus t


For running api_tester:

	rake setup:api_test_app
	script/api_tester.rb

