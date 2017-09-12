class TelegramDivisionController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  context_to_action!

  def start(*)
    respond_with :message, text: 'Divisiom'
  end

  def help(*)
    respond_with :message, text: t('.content')
  end

  def message(message)
    bot.forward_message message_id: message['message_id'], from_chat_id: message['chat']['id'], chat_id: Rails.application.secrets['telegram']['me']
    bot.send_message chat_id: Rails.application.secrets['telegram']['me'], text: parse(message, message_type(message))
  end

  private

  def division_report
  end
end
