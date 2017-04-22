require 'json'
require 'sinatra'
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
    # Refactor into DrinkBot Method
    place_details = nil
    Thread.new do
      drinkbot.open_im_channels
      request_location = params["text"].split(' at ').drop(1).join("+")
      resp = google.geocode(request_location)
      if resp["results"].none?
        # Do Something
      else
        location = resp["results"][0]["geometry"]["location"]
        bars = google.get_nearest_bars(location)
        place_id = bars["results"][0]["place_id"]
        place_details = google.get_place_details(place_id)

        drinkbot.send_initial_ims
        drinkbot.post_initial_message
      end
    end
    200
  end
end

post '/actions-endpoint' do
  content_type :json

  payload = JSON.parse(params[:payload])
  response = payload["actions"][0]["value"]
  action = payload["actions"][0]["name"]
  responder = payload["user"]

  case action
  when 'drinks_response'
    return "This request for hangs is out of date" if drinkbot.response_out_of_date?(payload)
    drinkbot.update_initial_im(payload, response)
    drinkbot.update_initial_message(responder, response)
    drinkbot.post_location_suggestion(place_details) if response == "yes"
    200
  when 'location_response'
    drinkbot.create_cal_event(drinkbot.day, place_details)
    drinkbot.upload_cal_event
    200
  else
    "That hasn't been programmed yet."
  end
end
