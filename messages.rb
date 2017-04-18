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

  def Messages.private_drinks_acceptance_response(payload)

    attachments = [
      {
        title: "Cool, I'll help you plan it.",
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

end