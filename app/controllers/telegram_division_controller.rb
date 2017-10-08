require 'digest/md5'
class TelegramDivisionController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include ApplicationHelper
  include Parsed

  before_action :set_division, only: [:summary, :users]
  before_action :set_user, only: [:me, :give, :message]
  before_action :set_admin, only: [:users, :divisions, :autopin, :pin_message]
  before_action :find_division, only: [:autopin, :pin_message]

  before_action :check_achivment, only: [:message]

  context_to_action!

  def start(*)
    respond_with :message, text: t('.content')
  end

  def help(*)
    respond_with :message, text: t('.content')
  end

  def message(message)
    type = message_type(message)
    return if type == :parse_undefined
    private_message, public_message = parse(message, type)
    #respond_with :message, text: public_message if message['chat']['type'] == 'private'
    bot.send_message chat_id: Rails.application.secrets['telegram']['me'], text: private_message if private_message
    respond_with :message, text: public_message if public_message
  end

  def summary
    respond_with :message, text: summary_report(@division), parse_mode: 'Markdown'
  end

  def hashtags
    respond_with :message, text: t('.content')
  end

  def give(value)
    @user.add_achivment(Achivment.first) if Digest::MD5.hexdigest @user.game_name == value
  end

  def me
    respond_with :message, text: user_report(@user), parse_mode: 'Markdown'
  end

  def achivments
    respond_with :message, text: achivments_report(@user, true)
  end

  def autopin(value)
    @division.update_attributes(autopin: value)
    respond_with :message, text: "Для #{@division.title} автопин #{value}"
  end

  def autopin_nighty(value)
    @division.update_attributes(autopin_nighty: value)
    respond_with :message, text: "Для #{@division.title} вечерний автопин #{value}"
  end

  def pin_message(*args)
    @division.update_attributes(message: args.join(' '))
    respond_with :message, text: "Для #{@division.title} установлено сообщение автопина #{args.join(' ')}"
  end

  def pin_message_nighty(*args)
    @division.update_attributes(nighty_message: args.join(' '))
    respond_with :message, text: "Для #{@division.title} установлено сообщение вечернего автопина #{args.join(' ')}"
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
    divisions = @admin.moderated_divisions
    respond_with :message, text: users_report(divisions), parse_mode: 'Markdown', disable_web_page_preview: true
  end

  def move_out(id)
    user = User.find(id)
    respond_with :message, text: "#{user.game_name} выгнан из #{user.division.title}"
    user.move
  end

  def move(id)
    user = User.find(id)
    user.move(session[:division])
    respond_with :message, text: "#{user.game_name} переведен в #{user.division.title}"
  end

  def update_admin
    admins = bot.get_chat_administrators chat_id: @division.telegram_id
    admins.each do |admin|
      user = User.find_by_telegram_id(admin['user']['id'])
      next unless user
      user.update_attributes(type: 'Admin') unless user.admin?
      admin = Admin.find_by_telegram_id(admin['user']['id'])
      admin.moderated_divisions << @division if user.moderated_divisions.include?(@division)
    end
  end

  private

  def check_achivment
    @user.check_achivment(update['message']) if @user && @user.id == 2
  end

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
