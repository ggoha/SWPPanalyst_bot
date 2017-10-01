class TelegramDivisionController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include ApplicationHelper
  include Parsed

  before_action :set_division, only: [:summary, :users]
  before_action :set_user, only: [:me]
  before_action :set_admin, only: [:users, :divisions, :autopin, :pin_message]
  before_action :find_division, only: [:autopin, :pin_message]

  context_to_action!

  def start(*)
    respond_with :message, text: t('.content')
  end

  def help(*)
    respond_with :message, text: t('.content')
  end

  def message(message)
    type = message_type(message)
    if type != :parse_undefined
      private_nessage, public_message = parse(message, type)
      respond_with :message, text: public_message if message['chat']['type'] == 'private'
      bot.send_message chat_id: Rails.application.secrets['telegram']['me'], text: private_nessage
    end
  end

  def summary
    respond_with :message, text: summary_report(@division), parse_mode: 'Markdown'
  end

  def hashtags
    respond_with :message, text: t('.content')
  end

  def me
    respond_with :message, text: user_report(@user), parse_mode: 'Markdown'
  end

  def autopin(value)
    @division.update_attributes(autopin: value)
    respond_with :message, text: "Для #{@division.title} автопин #{value}"
  end

  def pin_message(*args)
    @division.update_attributes(message: args.join(' '))
    respond_with :message, text: "Для #{@division.title} установлено сообщение автопина #{args.join(' ')}"
  end

  def divisions
    respond_with :message, text: 'Выбери отдел', reply_markup: {
      inline_keyboard: [@admin.moderated_divisions.map { |d| { text: d.title, callback_data: d.id.to_s } }]
    }    
  end

  def callback_query(data)
    session[:division] = data
  end

  def users
    respond_with :message, text: users_report(@admin.moderated_divisions), parse_mode: 'Markdown', disable_web_page_preview: true
  end

  private

  def set_division
    @division = Division.find_by_telegram_id(update['message']['chat']['id'])
  end

  def find_division
    @division = Division.find(session[:division])
  end

  def set_user
    @user = User.find_by_telegram_id(update['message']['from']['id'])
  end

  def set_admin
    @admin = Admin.find_by_telegram_id(update['message']['from']['id'])
    throw :abort unless @admin
  end
end
