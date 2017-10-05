class TelegramParserController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Parsed

  context_to_action!

  def start(*)
    respond_with :message, text: t('.content')
  end

  def help(*)
    respond_with :message, text: t('.content')
  end

  def channel_post(message)
    if from_report_chat?(message)
      bot.send_message chat_id: Rails.application.secrets['telegram']['me'], text: parse(message, message_type(message))
    else
      bot.send_message chat_id: Rails.application.secrets['telegram']['me'], text: t('.wrong')
    end
  end

  private

  def from_report_chat?(message)
    message['chat']['id'] == Rails.application.secrets['telegram']['report']
  end
end
