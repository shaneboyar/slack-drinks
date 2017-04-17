require 'sinatra'
require 'httparty'
require 'json'

post '/gateway' do
  content_type :json
  {
    response_type: "in_channel",
    text: "You wanna get drinks #{params[:text]}?",
    attachments: [
      {
        callback_id: "accept_response",
        attachment_type: "default",
        actions: [
          {
            "name": "accept_response",
            "text": "Yep",
            "type": "button",
            "value": 'yes'
          },
          {
            "name": "accept_response",
            "text": "Nah",
            "type": "button",
            "value": 'no'
          }
        ]
      }
    ]
  }.to_json
end

post '/actions-endpoint' do
  content_type :json
  response = JSON.parse(params[:payload])["actions"][0]["value"]
  case JSON.parse(params[:payload])["actions"][0]["name"]
  when 'accept_response'
    response == "yes" ? 'Cool' : "Boo, you whore."
  else "That hasn't been programmed yet."
  end
end
