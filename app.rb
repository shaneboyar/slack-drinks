require 'sinatra'
require 'json'
require 'jbuilder'
require './api'
require './messages'

slack = Slack.new("xoxb-169744296672-Rwk78bwajqgD0tjGE0w28XGK")
last_public_bot_message = nil

post '/gateway' do
  content_type :json
  case params[:text]
  when 'help'
    {
      response_type: "ephemeral",
      text: "How to use /drinks",
      attachments: [
        {
          text: "To start planning drinks type `/drinks` followed by when you'd like to get drinks (e.g. `/drinks tonight` or `/drinks this friday`"
        }
      ]
    }.to_json
  else
    channel_member_ids = slack.get_channel_members({channel: params["channel_id"]}).each do |user_id|
      payload = {
        user: user_id,
        return_im: "true"
      }
      slack.open_im_with_user(payload)
    end
    slack.list_im_channel_ids(channel_member_ids).each do |im_channel_id|
      payload = {requester: params['user_name'], day: params["text"], channel: im_channel_id} #FIX!!!
      slack.post_message(Messages.private_drinks_request(payload))
      nil
    end
    last_public_bot_message = slack.post_message(Messages.public_drinks_request(params))
    return nil
  end
end

post '/actions-endpoint' do
  content_type :json

  payload = JSON.parse(params[:payload])
  response = payload["actions"][0]["value"]
  action = payload["actions"][0]["name"]
  case action
  when 'drinks_response'
    if response == "yes"
      payload[:channel] = last_public_bot_message["channel"]
      slack.update_message(Messages.private_drinks_acceptance_response(payload))
      new_message = {
        channel: last_public_bot_message["channel"],
        ts: last_public_bot_message["ts"],
        title: last_public_bot_message["message"]["attachments"][0]["title"],
        original_message: last_public_bot_message["message"]["attachments"][0]["text"]
      }
      last_public_bot_message = slack.update_message(Messages.public_drinks_acceptance_response(payload, new_message))
      return nil
    elsif response == "no"
      payload[:channel] = last_public_bot_message["channel"]
      slack.update_message(Messages.private_drinks_denial_response(payload))
      new_message = {
        channel: last_public_bot_message["channel"],
        ts: last_public_bot_message["ts"],
        title: last_public_bot_message["message"]["attachments"][0]["title"],
        original_message: last_public_bot_message["message"]["attachments"][0]["text"]
      }
      last_public_bot_message = slack.update_message(Messages.public_drinks_denial_response(payload, new_message))
      return nil
    end
  else
    "That hasn't been programmed yet."
  end
end
