class TelegramAdminController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include ApplicationHelper
  
  context_to_action!

  def start(*)
    respond_with :message, text: t('.content')
  end

  def help(*)
    respond_with :message, text: t('.content')
  end

  def summary(*)
    if from_admin_chat?(update['message'])
      respond_with :message, text: company_summary_report(Company.our), parse_mode: 'Markdown'
    else
      bot.send_message chat_id: Rails.application.secrets['telegram']['me'], text: t('.wrong')
    end
  end

  private

  def from_admin_chat?(message)
    message['chat']['id'] == Rails.application.secrets['telegram']['admin']
  end
end
