require 'httparty'
require 'json'


class Slack
  include HTTParty
  base_uri 'https://slack.com/api'
  debug_output

  def initialize(token)
    @token = token
  end

  def test_api
    self.class.post('/api.test').tap do |response|
      puts "*********#{response}**********"
      raise "error: #{response.fetch('error')}" unless response['ok']
    end
  end

  def test_auth
    self.class.post('/auth.test').tap do |response|
      puts "*********#{response}**********"
      raise "error: #{response.fetch('error')}" unless response['ok']
    end
  end

  def list_channels
    self.class.post('/channels.list', body: {token: @token}, options: {headers: {'Content-Type': 'application/json'}}).tap do |response|
      raise "error posting message: #{response.fetch('error', 'unknown error')}" unless response['ok']
    end
  end

  def post_message(params)
    self.class.post('/chat.postMessage', body: params.merge({token: @token}), options: {headers: {'Content-Type': 'application/json'}}).tap do |response|
      raise "error posting message: #{response.fetch('error', 'unknown error')}" unless response['ok']
    end
  end

  def update_message(params)
    self.class.post('/chat.update', body: params.merge({token: @token}), options: {headers: {'Content-Type': 'application/json'}}).tap do |response|
      raise "error updating message: #{response.fetch('error', 'unknown error')}" unless response['ok']
    end
  end

  def debug
    puts "I'm Here!"
  end
end