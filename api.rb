require 'httparty'
require 'json'

class Google
  include HTTParty
  base_uri 'https://maps.googleapis.com/maps/api'
  debug_output

  def initialize(key)
    @key = key
  end

  def geocode(address)
    self.class.get("/geocode/json?address=#{address}&key=#{@key}").tap do |response|
      raise "error #{response["error_message"]}" unless response["status"] == "OK"
    end
  end

  def get_nearest_bars(geocoded_location)
    self.class.get("/place/nearbysearch/json?location=#{geocoded_location["lat"]},#{geocoded_location["lng"]}&rankby=distance&type=bar&key=#{@key}").tap do |response|
      raise "error #{response["error_message"]}" unless response["status"] == "OK"
    end
  end

  def get_place_details(place_id)
    self.class.get("/place/details/json?placeid=#{place_id}&key=#{@key}").tap do |response|
      raise "error #{response["error_message"]}" unless response["status"] == "OK"
    end
  end
end


class Slack
  include HTTParty
  base_uri 'https://slack.com/api'
  debug_output

  def initialize(token)
    @token = token
  end

  def test_api
    self.class.post('/api.test').tap do |response|
      raise "error: #{response.fetch('error')}" unless response['ok']
    end
  end

  def test_auth
    self.class.post('/auth.test').tap do |response|
      raise "error: #{response.fetch('error')}" unless response['ok']
    end
  end

  def list_channels
    self.class.post('/channels.list', body: {token: @token}, options: {headers: {'Content-Type': 'application/json'}}).tap do |response|
      raise "error listing channels: #{response.fetch('error', 'unknown error')}" unless response['ok']
    end
  end

  def get_channel_info(params)
    self.class.post('/channels.info', body: params.merge({token: @token}), options: {headers: {'Content-Type': 'application/json'}}).tap do |response|
      raise "error getting info: #{response.fetch('error', 'unknown error')}" unless response['ok']
    end
  end

  def get_channel_members(params)
    self.class.post('/channels.info', body: params.merge({token: @token}), options: {headers: {'Content-Type': 'application/json'}}).tap do |response|
      raise "error getting channel members: #{response.fetch('error', 'unknown error')}" unless response['ok']
      return response["channel"]["members"]
    end
  end

  def open_im_with_user(params)
    self.class.post('/im.open', body: params.merge({token: @token}), options: {headers: {'Content-Type': 'application/json'}}).tap do |response|
      raise "error opening IM with user: #{response.fetch('error', 'unknown error')}" unless response['ok']
    end
  end

  def list_im_channel_ids(user_ids)
    self.class.post('/im.list', body: {token: @token}, options: {headers: {'Content-Type': 'application/json'}}).tap do |response|
      raise "error listing IM channels: #{response.fetch('error', 'unknown error')}" unless response['ok']
      ids = []
      response["ims"].each do |im|
        ids << im["id"] if user_ids.include?(im["user"])
      end
      return ids
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

  # BROKED
  # def upload_file(params)
  #   self.class.post('/files.upload', body: params.merge({token: @token}), options: {headers: {'Content-Type': 'application/json'}}).tap do |response|
  #     raise "error updloading file: #{response.fetch('error', 'unknown error')}" unless response['ok']
  #   end
  # end

  def debug
    puts "I'm Here!"
  end
end