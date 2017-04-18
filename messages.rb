module Messages

  def Messages.drinks_request(params)
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
          title: "@#{params['user_name']} wants to get drinks #{params["text"]}",
          text: "You down?",
          color: "#7CD197",
          attachment_type: "default",
          callback_id: "drinks_response",
          actions: actions
      }
    ].to_json

    drinks_request = {
      channel: params["channel_id"],
      attachments: attachments
    }
  end

  def Messages.drinks_response(payload)
    updated_text = if payload["original_message"]["attachments"][0]["text"] == "You down?"
      "#{payload["user"]["name"]} is down."
    else
      payload["original_message"]["attachments"][0]["text"] + " #{payload["user"]["name"]} is down."
    end

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
        title: payload["original_message"]["attachments"][0]["title"],
        text: updated_text,
        color: "#7CD197",
        attachment_type: "default",
        callback_id: "drinks_response",
        actions: actions,
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