module Messages

  def Messages.public_drinks_request(params)
    attachments = [
      {
        title: "#{params['user_name']} wants to get drinks #{params["text"]}",
        text: "Check your private chat with @drinkbot to respond",
        color: "#7CD197",
        attachment_type: "default"
      }
    ].to_json

    drinks_request = {
      channel: params["channel_id"],
      attachments: attachments
    }
  end

  def Messages.public_location_suggestion(params)
    attachments = [
      {
        fallback: 'Wanna go here?',
        pretext: 'Wanna go here?',
        color: "#36a64f",
        title: params["result"]["name"],
        title_link: params["result"]["url"],
        text: params["result"]["vicinity"],
        image_url: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=#{params["result"]["photos"][0]["photo_reference"]}&key=AIzaSyCc_VAlXcj_ZsJvw3sIDWJSVkuDKChsMbk"
      }
    ].to_json
    location_suggestion = {
      channel: params[:channel_id],
      attachments: attachments
    }
  end

  def Messages.private_drinks_request(payload)
    actions = [
      {
        name: "drinks_response",
        text: "Yes",
        type: "button",
        value: "yes"
      },
      {
        name: "drinks_response",
        text: "Nah",
        type: "button",
        value: "no"
      }
    ]

    attachments = [
      {
          title: "#{payload[:requester]} wants to get drinks #{payload[:day]}",
          text: "You down?",
          color: "#7CD197",
          attachment_type: "default",
          callback_id: "drinks_response",
          actions: actions
      }
    ].to_json

    drinks_request = {
      channel: payload[:channel],
      attachments: attachments
    }
  end

  def Messages.public_drinks_acceptance_response(payload, new_message)
    updated_text = if new_message[:original_message] == "Check your private chat with @drinkbot to respond"
      "<@#{payload["user"]["id"]}|#{payload["user"]["name"]}> is down."
    else
      new_message[:original_message] + " <@#{payload["user"]["id"]}|#{payload["user"]["name"]}> is down."
    end

    attachments = [
      {
        title: new_message[:title],
        text: updated_text,
        color: "#7CD197",
        attachment_type: "default"
      }
    ].to_json

    drinks_response = {
      channel: new_message[:channel],
      ts: new_message[:ts],
      attachments: attachments,
      as_user: "true"
    }
  end

  def Messages.public_drinks_denial_response(payload, new_message)
    updated_text = if new_message[:original_message] == "Check your private chat with @drinkbot to respond"
      "<@#{payload["user"]["id"]}|#{payload["user"]["name"]}> can\'t make it."
    else
      new_message[:original_message] + " <@#{payload["user"]["id"]}|#{payload["user"]["name"]}> can\'t make it."
    end

    attachments = [
      {
        title: new_message[:title],
        text: updated_text,
        color: "#7CD197",
        attachment_type: "default"
      }
    ].to_json

    drinks_response = {
      channel: new_message[:channel],
      ts: new_message[:ts],
      attachments: attachments,
      as_user: "true"
    }
  end

  def Messages.private_drinks_acceptance_response(payload)
    attachments = [
      {
        title: "Cool, I'll help you plan it. Head back to <##{payload[:channel]}>",
        color: "#7CD197",
        attachment_type: "default"
      }
    ].to_json

    drinks_response = {
      channel: payload["channel"]["id"],
      ts: payload["original_message"]["ts"],
      attachments: attachments,
      as_user: "true"
    }
  end

  def Messages.private_drinks_denial_response(payload)
    attachments = [
      {
        title: "Ugh.",
        image_url: "https://media.tenor.co/images/1e88d8430b51b56de7c910f7aa2ce212/tenor.gif",
        color: "#CE2929",
        attachment_type: "default"
      }
    ].to_json

    drinks_response = {
      channel: payload["channel"]["id"],
      ts: payload["original_message"]["ts"],
      attachments: attachments,
      as_user: "true"
    }
  end

end