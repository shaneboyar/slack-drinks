require 'sinatra'
require 'json'
require 'jbuilder'
require './api'
require './messages'

slack = Slack.new("xoxb-169744296672-Rwk78bwajqgD0tjGE0w28XGK")

# slack.test_api
# resp = slack.list_channels
# test_channel_id = resp["channels"].map {|channel| channel['id'] if channel['name']=='test'}.compact.first


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
    slack.post_message(Messages.drinks_request(params))
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
      slack.update_message(Messages.drinks_response(payload))
      return nil
    end
  else
    "That hasn't been programmed yet."
  end
end

# headers: { 'Content-Type' => 'application/json', 'Accept' => 'application/json'},
# 'token': 'xoxb-169756502625-upP2EMgUaP6cj8CCs4oRfQbk',
# 'ts': payload['ts'],
# 'channel': payload['channel']['id'],
# 'text': payload['original_message']['text'] + ' ' + payload['user']['name'] + ' is in.',
# 'as_user': true
