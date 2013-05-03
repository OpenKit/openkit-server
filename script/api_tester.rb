#!/usr/bin/env ruby
#
# Setup:
#   $ rails c
#   > dev = Developer.create!(:email => "end_to_end@example.com", :name => "Test Developer", :password => "xxx", :password_confirmation => "xxx")
#   > app = dev.apps.create!(:name => "End to end test")
#   > app.update_attribute(:app_key, "end_to_end_test")
require 'debugger'
require 'json'
require 'rest-client'
require 'pp'
require 'oauth'

EP = "http://localhost:3000"
KEY = "end_to_end_test"        # Special app_key for running end to end tests on
SECRET = "TL5GGqzfItqZErcibsoYrNAuj7K33KpeWUEAYyyU"
CONSUMER = OAuth::Consumer.new(KEY, SECRET, {:site => EP})

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
  pp JSON.parse(res.body)
end

def post(path, req_params = {})
  blue "Response from POST to #{path}:"
  res = CONSUMER.request(:post, path, nil, {}, req_params.to_json, { 'Accept' => 'application/json', 'Content-Type' => 'application/json' })
  response_log(res)
  res
end

def delete(path)
  blue "Response from DELETE to #{path}:"
  res = CONSUMER.request(:delete, path, nil, {}, { 'Accept' => 'application/json' })
  response_log(res)
  res
end

def get(path, req_params = {})
  blue "Response from GET to #{path}:"
  if !req_params.empty?
    path += "?" + req_params.collect { |k, v| "#{k.to_s}=#{CGI::escape(v.to_s)}" }.join('&')
  end
  res = CONSUMER.request(:get, path, nil, {}, { 'Accept' => 'application/json' })
  response_log(res)
  res
end

# Makes a special request to purge data associated with end_to_end_test app.  Hack.  In the future
# we'll have a test instance up to blast with data.
res = delete '/purge_test_data'
if res.code != "200"
  puts "Could not purge test data, maybe you do not have an app with app key #{KEY} on #{EP}?"
  exit 1
end

# Create some users
res1 = post '/users',              { user: {nick: "test user 1", custom_id: 454} }
res2 = post '/users',              { user: {nick: "test user 2", custom_id: 600} }
user1 = JSON.parse(res1.body)
user2 = JSON.parse(res2.body)

# Create a couple leaderboards
res1 = post '/leaderboards',       { leaderboard: {name: 'leader 1', sort_type: 'LowValue'} }
res2 = post '/leaderboards',       { leaderboard: {name: 'leader 2', sort_type: 'HighValue'} }
low_board = JSON.parse(res1.body)
high_board = JSON.parse(res2.body)

# List leaderboards
get '/leaderboards',               { }

# Create a couple achievements
res1 = post '/achievements',       { achievement: {name: 'achievement 1', desc: "Get x foos and receive a bar", points: 100, goal: 5 } }
res2 = post '/achievements',       { achievement: {name: 'achievement 2', desc: "Take some skins, jazz begins", points: 200, goal: 5 } }
ach1 = JSON.parse(res1.body)
ach2 = JSON.parse(res2.body)

# User 1 plays
post '/scores',                    { score: {leaderboard_id: low_board['id'], user_id: user1['id'], value: 9, display_string: "9 seconds!"} }
post '/scores',                    { score: {leaderboard_id: low_board['id'], user_id: user1['id'], value: 10, display_string: "10 seconds!"} }
post '/achievement_scores',        { achievement_score: {achievement_id: ach1['id'], user_id: user1['id'], progress: 1}}
post '/achievement_scores',        { achievement_score: {achievement_id: ach1['id'], user_id: user1['id'], progress: 4}}

# User 2 plays
post '/scores',                    { score: {leaderboard_id: low_board['id'], user_id: user2['id'], value: 6, display_string: "6 seconds!"} }
post '/scores',                    { score: {leaderboard_id: low_board['id'], user_id: user2['id'], value: 12, display_string: "12 seconds!"} }

# Get user1 best
get '/best_scores/user',           { leaderboard_id: low_board['id'], user_id: user1['id'] }

# Get all best
get '/best_scores',                { leaderboard_id: low_board['id'], page_num: 1, num_per_page: 2 }

# List achievements
get '/achievements',               { }

# Get progress of all user 1 achievements for this app:
get '/achievements',               { user_id: user1['id'] }

