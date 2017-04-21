require 'sinatra'
require 'json'
require './api'
require './drinkbot'
require './messages'

slack = Slack.new("xoxb-169744296672-Rwk78bwajqgD0tjGE0w28XGK")
last_public_bot_message = nil
drinkbot = nil

iggys_by_location_payload = HTTParty.get('https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=40.7213411,-73.9888796&rankby=distance&type=bar&name=iggys&key=AIzaSyCc_VAlXcj_ZsJvw3sIDWJSVkuDKChsMbk')
iggys_place_id = iggys_by_location_payload["results"][0]["place_id"]
location = HTTParty.get("https://maps.googleapis.com/maps/api/place/details/json?placeid=#{iggys_place_id}&key=AIzaSyCc_VAlXcj_ZsJvw3sIDWJSVkuDKChsMbk")

post '/gateway' do
  content_type :json
  drinkbot = Drinkbot.new(params)

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
    drinkbot.open_im_channels
    drinkbot.send_initial_ims
    last_public_bot_message = drinkbot.post_initial_message
    nil
  end
end

post '/actions-endpoint' do
  content_type :json

  payload = JSON.parse(params[:payload])
  response = payload["actions"][0]["value"]
  action = payload["actions"][0]["name"]
  responder = payload["user"]

  return "This request for hangs is out of date" if drinkbot.response_out_of_date?(payload)

  case action
  when 'drinks_response'
      drinkbot.update_initial_im(payload, response)
      drinkbot.update_initial_message(responder, response)
      drinkbot.post_location_suggestion(location) if response == "yes"
      return nil
  else
    "That hasn't been programmed yet."
  end
end
