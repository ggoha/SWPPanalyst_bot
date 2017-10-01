class TelegramAdminController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext

  context_to_action!

  def start(*)
    respond_with :message, text: 'Admin'
  end

  def help(*)
    respond_with :message, text: t('.content')
  end

  def summary
    if update['message']['chat']['id']==Rails.application.secrets['telegram']['admin']
      respond_with :message, text: company_summary_report(Company.our), parse_mode: 'Markdown'
    else
      bot.send_message chat_id: Rails.application.secrets['telegram']['me'], text: 'неправильный канал'
    end
  end
end
