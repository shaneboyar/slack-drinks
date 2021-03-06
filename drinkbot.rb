require 'chronic'
require 'icalendar'
require 'json'
require './api'
require './messages'
require 'dotenv/load'

class Drinkbot
  @@array = Array.new
  attr_reader :day
  attr_reader :initial_request_responses
  attr_reader :id

  def self.all_instances
    @@array
  end

  def initialize(initial_params)
    @id = Time.now.to_i
    @slack = Slack.new(ENV['SLACK_API_TOKEN'])
    @initial_params = initial_params
    @requester = initial_params[:user_name]
    @day = initial_params[:text].split(" at ")[0]
    @request_room_id = initial_params["channel_id"]
    @request_room_name = initial_params["channel_name"]
    @friend_ids = @slack.get_channel_members({channel: initial_params["channel_id"]}) # Need to filter out inactive members
    @initial_message = nil
    @im_channel_ids = []
    @initial_request_responses = []
    @@array << self
  end

  def open_im_channels
    @friend_ids.each do |id|
      resp = @slack.open_im_with_user({user: id})
      @im_channel_ids << resp["channel"]["id"]
    end
  end

  def send_initial_ims
    @timestamps = []
    @im_channel_ids.each do |im_channel_id|
      payload = {requester: @requester, day: @day, channel: im_channel_id, callback_id: @id}
      resp = @slack.post_message(Messages.private_drinks_request(payload))
      @timestamps << resp["ts"]
    end
    @timestamps
  end

  def response_out_of_date?(payload)
    !@timestamps.include?(payload["message_ts"])
  end

  def update_initial_im(payload, response)
    params = payload.merge({channel: @request_room_id})
    if response == "yes"
      @slack.update_message(Messages.private_drinks_acceptance_response(params))
    else
      @slack.update_message(Messages.private_drinks_denial_response(params))
    end

  end

  def post_initial_message
    @initial_message = @slack.post_message(Messages.public_drinks_request(@initial_params))
    set_initial_message(@initial_message)
    return @initial_message
  end

  def set_initial_message(response)
    @initial_message = response
  end

  def update_initial_message(responder, response)
    old_message = {
        channel: @initial_message["channel"],
        ts: @initial_message["ts"],
        title: @initial_message["message"]["attachments"][0]["title"],
        original_message_text: @initial_message["message"]["attachments"][0]["text"]
      }
    if response == "yes"
      set_initial_message(@slack.update_message(Messages.public_drinks_acceptance_response(responder, old_message)))
    else
      set_initial_message(@slack.update_message(Messages.public_drinks_denial_response(responder, old_message)))
    end
  end

  def capture_initial_request_responses(payload)
    @initial_request_responses << payload
  end


  def post_location_suggestion(location)
    params = location.merge({channel_id: @request_room_id, callback_id: @id})
    @slack.post_message(Messages.public_location_suggestion(params))
  end

  def create_cal_event(time, place)
    time = Chronic.parse(time)
    place_name = place["result"]["name"]
    cal = Icalendar::Calendar.new
    cal.event do |event|
      event.dtstart = DateTime.civil(time.year, time.month, time.day, time.hour, time.min)
      event.summary     = "Drinks at #{place_name}"
      event.description = "address is here....."
    end
    cal.publish
    file = File.new("./cal.ics", "w+")
    file.write(cal.to_ical)
    file.close
  end

  def upload_cal_event # THIS SUCKS!
    system("curl -F file=@cal.ics -F channels=#{@im_channel_ids.join(",")} -F token=#{ENV['SLACK_API_TOKEN']} https://slack.com/api/files.upload")
    File.delete('./cal.ics')
  end


end