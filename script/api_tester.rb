#!/usr/bin/env ruby
# encoding: utf-8
#
# Setup:
#   $ rails c
#   > dev = Developer.create!(:email => "end_to_end@example.com", :name => "Test Developer", :password => "password", :password_confirmation => "password")
#   > app = dev.apps.create!(:name => "End to end test")
#   > app.update_attribute(:app_key, "end_to_end_test")
#   > app.update_attribute(:secret_key, "TL5GGqzfItqZErcibsoYrNAuj7K33KpeWUEAYyyU")


#
# Usage:
#   $ SSL_CERT_FILE="/usr/local/etc/nginx/ssl/ok_wildcard.pem" ruby script/api_tester.rb
# Or
#   $ SSL_CERT_FILE="/usr/local/etc/nginx/ssl/ok_wildcard.pem" script/api_tester.rb
# Notes:
#   * Ruby wants the cert in pem format.

require 'securerandom'
require 'net/http'
require 'digest/hmac'
require 'base64'
require 'cgi'
require 'json'
require 'debugger'


class Req

  def escape(s)
    CGI.escape(s)
  end

  def initialize
    @appKey = "end_to_end_test"
    @secretKey = "TL5GGqzfItqZErcibsoYrNAuj7K33KpeWUEAYyyU"
    @timestamp = Time.now.to_i
    @nonce = SecureRandom.uuid
    @scheme = "https://"
    @host = "local.openkit.io"
  end


  def get(path, params = {})
    @verb = "GET"
    query_string = params.empty? ? '' : params.collect { |k, v| "#{k.to_s}=#{v.to_s}" }.join('&')
    builder = @scheme + @host + path
    builder << "?#{query_string}" if !query_string.empty?
    @uri = URI(builder)
    @klass = Net::HTTP::Get
    @include_params = params
    request()
  end

  def delete(path)
    @verb = "DELETE"
    @uri = URI(@scheme + @host + path)
    @klass = Net::HTTP::Delete
    request()
  end

  def put(path, params)
    @verb = "PUT"
    @uri = URI(@scheme + @host + path)
    @klass = Net::HTTP::Put
    @request_body = params.to_json
    request()
  end


  def post(path, params)
    @verb = "POST"
    @uri = URI(@scheme + @host + path)
    @klass = Net::HTTP::Post
    @request_body = params.to_json
    request()
  end

  private
  def request()
    Net::HTTP.start(@uri.host, @uri.port, :use_ssl => true) do |http|
      request = @klass.new(@uri.request_uri)
      request.set_body_internal(@request_body) if @request_body
      request['Content-Type'] = "application/json; charset=utf-8"
      request['Accept'] = "application/json"

      h_params = {
        oauth_consumer_key:       @appKey,
        oauth_nonce:              @nonce,
        oauth_signature_method:   'HMAC-SHA1',
        oauth_timestamp:          @timestamp,
        oauth_version:            '1.0',
      }
      if @include_params && !@include_params.empty?
        h_params.merge!(@include_params)
      end

      sorted_params_str = h_params.sort_by{|k, _| k}.collect{ |k,v| k.to_s + '=' + v.to_s }.join("&")
      signatureBaseString = "#{@verb}&#{escape(@scheme + @host + @uri.path)}&#{escape(sorted_params_str)}"
      k = "#{@secretKey}&"
      hmac = Digest::HMAC.digest(signatureBaseString, k, Digest::SHA1)
      signature = Base64.encode64(hmac).chomp

      request['Authorization'] = "OAuth oauth_consumer_key=\"#{@appKey}\", oauth_nonce=\"#{@nonce}\", oauth_signature=\"#{escape(signature)}\", oauth_signature_method=\"HMAC-SHA1\", oauth_timestamp=\"#{@timestamp}\", oauth_version=\"1.0\""
      http.request request do |response|
      end
    end
  end
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

# Makes a special request to purge data associated with end_to_end_test app.  Hack.  In the future
# we'll have a test instance up to blast with data.
res = delete '/v1/purge_test_data'
if res.code != "200"
  puts "Could not purge test data, maybe you do not have an app with app key #{KEY} on #{EP}?"
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

