#!/usr/bin/env ruby
# encoding: utf-8
#
# Setup:
#   $ rake setup:api_test_app
#
# Usage:
#   $ script/api_tester.rb
#
# Without built-in server:
#   $ HOST=localhost:3000 script/api_tester.rb
#
# With ssl:
#   $ <start-nginx>
#   $ bundle exec thin -V start --socket /tmp/thin.sock
#   $ HOST=localhost SSL_CERT_FILE="ok_wildcard.pem" script/api_tester.rb
#
# Notes:
#   * Ruby wants the cert in pem format.

require File.expand_path("../../../clients/ruby/openkit.rb", __FILE__)

#require 'debugger'

if !ENV['HOST']
  puts "Starting thin..."
  Dir.chdir(File.expand_path('../..', __FILE__)) do
    @io = IO.popen("bundle exec thin start -p 3003")
  end

  while line = @io.gets
    print line
    break if line =~ /^Listening on/
  end
  sleep 0.2
end


def blue(msg)
  printf "\n\e[44m #{msg} \e[0m\n"
end

def red(msg)
  printf "\n\e[41m #{msg} \e[0m\n"
end

def response_log(res)
  if res.code !~ /^20./
    red "code: #{res.code}"
  end
  if res.body && res.body != " "  # When using 'head :ok', we get a response body of a single space.  Not sure why.
    pp JSON.parse(res.body)
  end
end

def post(path, req_params = {})
  blue "Response from POST to #{path}:"
  res = Req.new.post(path, req_params)
  response_log(res)
  res
end

def multi_post(path, req_params, upload)
  blue "Response from Multipart POST to #{path}:"
  res = Req.new.multipart_post(path, req_params, upload)
  response_log(res)
  res
end

def delete(path)
  blue "Response from DELETE to #{path}:"
  res = Req.new.delete(path)
  response_log(res)
  res
end

def put(path, req_params = {})
  blue "Response from PUT to #{path}:"
  res = Req.new.put(path, req_params)
  response_log(res)
  res
end

def get(path, req_params = {})
  blue "Response from GET to path #{path} with params: #{req_params.inspect}:"
  res = Req.new.get(path, req_params)
  response_log(res)
  res
end

Req.skip_https = !ENV['SSL_CERT_FILE']
if Req.skip_https
  puts "No SSL_CERT_FILE specified.  using http."
end

# Makes a special request to purge data associated with end_to_end_test app.  Hack.  In the future
# we'll have a test instance up to blast with data.
res = delete '/v1/purge_test_data'
if res.code != "200"
  puts "Could not purge test data.  Try 'rake setup:api_test_app'"
  exit 1
end

# Create some users
res1 = post '/v1/users',              { user: {nick: "test utf8 user ěáð汉语", custom_id: "454"} }
res2 = post '/v1/users',              { user: {nick: "test user 2", custom_id: "600"} }
user1 = JSON.parse(res1.body)
user2 = JSON.parse(res2.body)

# Create a couple leaderboards
res1 = post '/v1/leaderboards',       { leaderboard: {name: 'leader 1', sort_type: 'LowValue', tag_list:"v1"} }
res2 = post '/v1/leaderboards',       { leaderboard: {name: 'leader 2', sort_type: 'HighValue', tag_list:"v1,v2"} }
low_board = JSON.parse(res1.body)
high_board = JSON.parse(res2.body)

# List leaderboards
get '/v1/leaderboards'

# List leaderboards with a certain tag:
get '/v1/leaderboards',    {tag: 'v2'}

# Show a leaderboard
get "/v1/leaderboards/#{high_board['id']}"

# Create a couple achievements
res1 = post '/v1/achievements',       { achievement: {name: 'achievement 1', desc: "Get x foos and receive a bar", points: 100, goal: 5 } }
res2 = post '/v1/achievements',       { achievement: {name: 'achievement 2', desc: "Take some skins, jazz begins", points: 200, goal: 5 } }
ach1 = JSON.parse(res1.body)
ach2 = JSON.parse(res2.body)

# User 1 plays
post '/v1/scores',                    { score: {leaderboard_id: low_board['id'], user_id: user1['id'], value: 9, display_string: "9 seconds!"} }
post '/v1/scores',                    { score: {leaderboard_id: low_board['id'], user_id: user1['id'], value: 10, display_string: "10 seconds!"} }
post '/v1/achievement_scores',        { achievement_score: {achievement_id: ach1['id'], user_id: user1['id'], progress: 1}}
post '/v1/achievement_scores',        { achievement_score: {achievement_id: ach1['id'], user_id: user1['id'], progress: 4}}

# User 2 plays
post '/v1/scores',                    { score: {leaderboard_id: low_board['id'], user_id: user2['id'], value: 6, display_string: "6 seconds!"} }
post '/v1/scores',                    { score: {leaderboard_id: low_board['id'], user_id: user2['id'], value: 12, display_string: "12 seconds!"} }

# Get user1 best
get '/v1/best_scores/user',           { leaderboard_id: low_board['id'], user_id: user1['id'] }

# Get all best
get '/v1/best_scores',                { leaderboard_id: low_board['id'], page_num: 1, num_per_page: 2 }

# List achievements
get '/v1/achievements',               { }

# Get progress of all user 1 achievements for this app:
get '/v1/achievements',               { user_id: user1['id'] }

# Update a user
put "/v1/users/#{user1['id']}",       { gamecenter_id: "234500000", fb_id: "12345" }

# Get a list of enabled features
get '/v1/features'


# Post a score with metadata document
meta_path = File.expand_path(File.join(File.dirname(__FILE__), 'immafile.txt'))
upload = Upload.new "score[meta_doc]", meta_path
multi_post '/v1/scores', { score: {leaderboard_id: low_board['id'], user_id: user1['id'], value: 11 }}, upload

if defined?(@io)
  Process.kill("INT", @io.pid)
  Process.waitpid(@io.pid)
  @io.close
end

