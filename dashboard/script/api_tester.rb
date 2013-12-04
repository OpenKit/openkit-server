#!/usr/bin/env ruby
# encoding: utf-8
#
# Setup:
#   $ rake maintenance:api_test_setup
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

require 'securerandom'
require 'net/http'
require 'net/http/post/multipart'
require 'digest/hmac'
require 'base64'
require 'cgi'
require 'json'
require 'debugger'

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


class Upload
  attr_accessor :param_name, :filepath

  def initialize(param_name, filepath)
    @param_name = param_name
    @filepath = filepath
  end

  def file
    @file ||= File.open(@filepath)
  end

  def close
    @file.close if @file  # Use ivar directly, not the #file method.
  end
end


# API:
#
# Get:
#   response = Req.new.get('/v1/leaderboards')
# Post:
#   response = Req.new.post('/v1/users', {:nick => 'lou'})
# Put:
#   response = Req.new.put('/v1/users/:id', {:nick => 'lou z'})
# Multipart Post:
#   upload = Upload.new('score[meta_doc]', 'path-to-file')    # The first param is the form param name to use for the file
#   response = Req.new.multipart_post('/v1/scores', {:score => {:value => 100}}, upload

class Req

  class << self; attr_accessor :skip_https; end;

  def initialize
    @app_key    = "end_to_end_test"
    @secret_key = "TL5GGqzfItqZErcibsoYrNAuj7K33KpeWUEAYyyU"
    @timestamp  = Time.now.to_i
    @nonce      = SecureRandom.uuid
    @scheme     = self.class.skip_https ? "http" : "https"
    @host       = ENV["HOST"] || "local.openkit.io:3003"
    @params_in_signature = {
      oauth_consumer_key:       @app_key,
      oauth_nonce:              @nonce,
      oauth_signature_method:   'HMAC-SHA1',
      oauth_timestamp:          @timestamp,
      oauth_version:            '1.0',
    }
  end


  def get(path, query_params = {})
    request(:get, path, query_params, nil)
  end

  def delete(path)
    request(:delete, path, nil, nil)
  end

  def put(path, req_params)
    request(:put, path, nil, req_params)
  end

  def post(path, req_params)
    request(:post, path, nil, req_params)
  end

  def multipart_post(path, req_params, upload)
    @upload = upload
    request(:post, path, nil, req_params)
  end

  def base_uri
    @scheme + "://" + @host
  end


  private
  def params_to_query(h)
    return '' if h.empty?
    h.collect { |k, v| "#{k.to_s}=#{v.to_s}" }.join('&')
  end

  def flat_names(parameters, running = '', &block)
    parameters.each do |k,v|
      name = (running.length == 0) ? k.to_s : running + "[#{k}]"
      if v.is_a?(Hash)
        flat_names(v, name, &block)
      else
        yield name, v
      end
    end
  end

  def flatten_params(parameters)
    flattened = {}
    flat_names(parameters, '') do |name,v|
      flattened[name] = v
    end
    flattened
  end

  def uri
    @uri ||= begin
      if is_get? && !@query_params.empty?
        URI(base_uri + @path + "?" + params_to_query(@query_params))
      else
        URI(base_uri + @path)
      end
    end
  end

  def is_get?
    @verb == :get
  end

  def is_post?
    @verb == :post && @upload.nil?
  end

  def is_multipart?
    @verb == :post && @upload
  end

  def is_put?
    @verb == :put
  end

  def is_delete?
    @verb == :delete
  end

  def net_klass
    is_get?    && Net::HTTP::Get    ||
    is_post?   && Net::HTTP::Post   ||
    is_put?    && Net::HTTP::Put    ||
    is_delete? && Net::HTTP::Delete ||
    (raise "Doing it wrong.")
  end


  def request(verb, path, query_params, req_params)
    @verb = verb
    @path = path
    @query_params = query_params
    @req_params = req_params

    if is_get?
      @params_in_signature.merge!(@query_params)
    end

    if is_put? || is_post?
      @request_body = req_params.to_json
    end

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true unless self.class.skip_https
    http.start do
      if is_multipart?
        flat_params = flatten_params(@req_params)
        request = Net::HTTP::Post::Multipart.new(@uri.request_uri, flat_params.merge(@upload.param_name => UploadIO.new(@upload.file, "application/octet-stream", "upload")))
      else
        request = net_klass.new(@uri.request_uri)
        request.set_body_internal(@request_body) if @request_body
        request['Content-Type'] = "application/json; charset=utf-8"
      end
      request['Accept'] = "application/json"
      request['Authorization'] = authorization_header
      response = http.request(request)
      @upload.close if @upload
      response
    end
  end


  def authorization_header
    %|OAuth oauth_consumer_key="#{@app_key}", oauth_nonce="#{@nonce}", oauth_signature="#{escape(signature)}", oauth_signature_method="HMAC-SHA1", oauth_timestamp="#{@timestamp}", oauth_version="1.0"|
  end

  def signature
    signatureBaseString = "#{@verb.to_s.upcase}&#{escape(base_uri + @uri.path)}&#{escape(params_string_for_signature)}"
    k = "#{@secret_key}&"  # <-- note the &
    hmac = Digest::HMAC.digest(signatureBaseString, k, Digest::SHA1)
    Base64.encode64(hmac).chomp
  end

  def params_string_for_signature
    @params_in_signature.sort_by{|k, _| k}.collect{ |k,v| k.to_s + '=' + v.to_s }.join("&")
  end

  def escape(s)
    CGI.escape(s)
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


# Post a score with metadata document
meta_path = File.expand_path(File.join(File.dirname(__FILE__), 'immafile.txt'))
upload = Upload.new "score[meta_doc]", meta_path
multi_post '/v1/scores', { score: {leaderboard_id: low_board['id'], user_id: user1['id'], value: 11 }}, upload

if defined?(@io)
  Process.kill("INT", @io.pid)
  Process.waitpid(@io.pid)
  @io.close
end

