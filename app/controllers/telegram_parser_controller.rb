class TelegramParserController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Parsed

  context_to_action!

  def start(*)
    respond_with :message, text: 'Parser'
  end

  def help(*)
    respond_with :message, text: t('.content')
  end

  def channel_post(message)
    bot.forward_message message_id: message['message_id'], from_chat_id: message['chat']['id'], chat_id: Rails.application.secrets['telegram']['me']
    bot.send_message chat_id: Rails.application.secrets['telegram']['me'], text: parse(message, message_type(message))
    #bot2send_picture
  end

  def message(message)
    bot.forward_message message_id: message['message_id'], from_chat_id: message['chat']['id'], chat_id: Rails.application.secrets['telegram']['me']
    bot.send_message chat_id: Rails.application.secrets['telegram']['me'], text: 'Обычное сообщение'
  end
end
