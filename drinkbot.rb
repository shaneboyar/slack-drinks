require 'json'
require './api'
require './messages'

class Drinkbot

  def initialize(initial_params)
    @slack = Slack.new("xoxb-169744296672-Rwk78bwajqgD0tjGE0w28XGK")
    @initial_params = initial_params
    @requester = initial_params[:user_name]
    @day = initial_params[:text]
    @request_room_id = initial_params["channel_id"]
    @request_room_name = initial_params["channel_name"]
    @friend_ids = @slack.get_channel_members({channel: initial_params["channel_id"]}) # Need to filter out inactive members
    @initial_message = nil
    @im_channel_ids = []
  end

  def open_im_channels
    @friend_ids.each do |id|
      resp = @slack.open_im_with_user({user: id})
      @im_channel_ids << resp["channel"]["id"]
    end
  end

  def send_initial_ims
    @im_channel_ids.each do |im_channel_id|
      payload = {requester: @requester, day: @day, channel: im_channel_id}
      resp = @slack.post_message(Messages.private_drinks_request(payload))
      nil
    end
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

  def post_location_suggestion(location)
    params = location.merge({channel_id: @request_room_id})
    @slack.post_message(Messages.public_location_suggestion(params))
  end


end