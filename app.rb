require 'sinatra'
require 'json'
require './api'
require './drinkbot'
require './messages'

slack = Slack.new("xoxb-169744296672-Rwk78bwajqgD0tjGE0w28XGK")
drinkbot = nil

google = Google.new("AIzaSyCc_VAlXcj_ZsJvw3sIDWJSVkuDKChsMbk")
place_details = nil

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
    initial_message = drinkbot.post_initial_message

    # Refactor into DrinkBot Method
    request_location = params["text"].split(' ').drop(1).join("+")
    resp = google.geocode(request_location)
    location = resp["results"][0]["geometry"]["location"]
    bars = google.get_nearest_bars(location)
    place_id = bars["results"][0]["place_id"]
    place_details = google.get_place_details(place_id)
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
      drinkbot.post_location_suggestion(place_details) if response == "yes"
      return nil
  else
    "That hasn't been programmed yet."
  end
end
