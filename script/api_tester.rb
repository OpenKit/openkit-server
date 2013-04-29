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

EP = "http://localhost:3000"
KEY = "end_to_end_test"        # Special app_key for running end to end tests on

def blue(msg)
  printf "\n\e[44m #{msg} \e[0m\n"
end

def post(path, req_params = {})
  blue "Response from POST to #{path}:"
  res = JSON.parse(RestClient.post(EP + path, req_params.to_json, {:content_type => :json, :accept => :json}))
  pp res
  res
end

def delete(path, req_params = {})
  blue "Response from DELETE to #{path}:"
  res = JSON.parse(RestClient.delete(EP + path, :accept => :json))
  pp res
  res
end

def get(path, req_params = {})
  blue "Response from GET to #{path}:"
  res = JSON.parse(RestClient.get(EP + path, {:params => req_params, :accept => :json, :content_type => :json}))
  pp res
  res
end

# Makes a special request to purge data associated with end_to_end_test app.  Hack.  In the future
# we'll have a test instance up to blast with data.
res = delete '/purge_test_data'
if !res['ok']
  puts "Could not purge test data, maybe you do not have an app with app key #{KEY} on #{EP}?"
  exit 1
end

# Create some users
user1 = post('/users',             { app_key: KEY, user: {nick: "test user 1", custom_id: 454} })
user2 = post('/users',             { app_key: KEY, user: {nick: "test user 2", custom_id: 600} })

# Create a couple leaderboards
low_board  = post '/leaderboards', { app_key: KEY, leaderboard: {name: 'leader 1', sort_type: 'LowValue'} }
high_board = post '/leaderboards', { app_key: KEY, leaderboard: {name: 'leader 2', sort_type: 'HighValue'}  }

# List leaderboards
get '/leaderboards',               { app_key: KEY }

# Create a couple achievements
ach1 = post '/achievements',       { app_key: KEY, achievement: {name: 'achievement 1', desc: "Get x foos and receive a bar", points: 100, goal: 5}  }
ach2 = post '/achievements',       { app_key: KEY, achievement: {name: 'achievement 2', desc: "Take some skins, jazz begins", points: 200, goal: 5}  }

# User 1 plays
post '/scores',                    { app_key: KEY, score: {leaderboard_id: low_board['id'], user_id: user1['id'], value: 9, display_string: "9 seconds!"}}
post '/scores',                    { app_key: KEY, score: {leaderboard_id: low_board['id'], user_id: user1['id'], value: 10, display_string: "10 seconds!"}}
post '/achievement_scores',        { app_key: KEY, achievement_score: {achievement_id: ach1['id'], user_id: user1['id'], progress: 1}}
post '/achievement_scores',        { app_key: KEY, achievement_score: {achievement_id: ach1['id'], user_id: user1['id'], progress: 4}}

# User 2 plays
post '/scores',                    { app_key: KEY, score: {leaderboard_id: low_board['id'], user_id: user2['id'], value: 6, display_string: "6 seconds!"}}
post '/scores',                    { app_key: KEY, score: {leaderboard_id: low_board['id'], user_id: user2['id'], value: 12, display_string: "12 seconds!"}}

# Get user1 best
get '/best_scores/user',           { app_key: KEY, leaderboard_id: low_board['id'], user_id: user1['id'] }

# Get all best
get '/best_scores',                { app_key: KEY, leaderboard_id: low_board['id'], page_num: 1, num_per_page: 2 }

# List achievements
get '/achievements',               { app_key: KEY }

# Get progress of all user 1 achievements for this app:
get '/achievements',               { app_key: KEY, user_id: user1['id'] }

