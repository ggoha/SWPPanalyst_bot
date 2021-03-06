require 'digest/md5'
require 'set'
class TelegramDivisionController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include ApplicationHelper
  include Parsed

  before_action :set_division, only: [:summary]
  before_action :set_user, only: [:me, :give, :message, :achievements, :walk, :history]
  before_action :set_admin, only: [:user, :users, :divisions, :autopin, :pin_message, :autopin_nighty, :pin_message_nighty, :move_out, :move, :update_admin]
  before_action :find_division, only: [:autopin, :pin_message, :autopin_nighty, :pin_message_nighty, :move_out, :move, :update_admin]

  context_to_action!

  def start(*)
    respond_with :message, text: t('.content')
  end

  def help(*)
    respond_with :message, text: t('.content')
  end

  def message(message)
    begin
      type = message_type(message)
      private_message, public_message = parse(message, type)
      return if type == :parse_undefined
      bot.send_message chat_id: Rails.application.secrets['telegram']['me'], text: private_message if private_message
      respond_with :message, text: public_message if public_message
    rescue StandardError => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n")
    end
  end
	def current_situation(*)
	end

  def level(*)
  end

  def mvp(*)
  end
  def mvp_reports(*)
  end

  def summary(*)
    begin
      binding.pry
      respond_with :message, text: summary_report(@division), parse_mode: 'Markdown'
    rescue StandardError => e
      Rails.logger.error e
    end
  end

  def hashtags(*)
    begin
      respond_with :message, text: t('.content')
    rescue StandardError => e
      Rails.logger.error e
    end
  end

  def give(*value)
    return unless @user
    @user.add_achivment(Achivment.first) if Digest::MD5.hexdigest(@user.game_name) == value[0]
  end

  def history(*)
    begin
    return unless @user
    respond_with :message, text: history_report(@user), parse_mode: 'Markdown'
    rescue StandardError => e
      Rails.logger.error e
    end    
  end

  def me(*)
    begin
    return unless @user
    respond_with :message, text: user_report(@user), parse_mode: 'Markdown'
    rescue StandardError => e
      Rails.logger.error e
    end
  end

  def user(*id)
    begin
      user = User.find id[0]
      return unless user
      return unless @admin.moderated_divisions.include? user.division
      respond_with :message, text: user_report(user), parse_mode: 'Markdown'
    rescue StandardError => e
      Rails.logger.error e
    end    
  end

  def achievements(*)
    return unless @user
    respond_with :message, text: achivments_report(@user, true)
  end

  def autopin(*value)
    @division.update_attributes(autopin: value[0])
    respond_with :message, text: "Для #{@division.title} автопин #{value}"
  end

  def autopin_nighty(*value)
    @division.update_attributes(autopin_nighty: value[0])
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

  def divisions(*)
    respond_with :message, text: 'Выбери отдел', reply_markup: {
      inline_keyboard: @admin.moderated_divisions.map { |d| { text: d.title, callback_data: d.id.to_s } }.each_slice(4).to_a
    }
  end

  def callback_query(data)
    session[:division] = data
  end

  def users(*)
    divisions = @admin.moderated_divisions
    users_report(divisions).each do |report|
      respond_with :message, text: report, parse_mode: 'Markdown', disable_web_page_preview: true
    end
  end

  def move_out(*ids)
    ids.each do |id|
      user = User.find(id)
      next unless user
      next unless @admin.moderated_divisions.include? user.division
      respond_with :message, text: "#{user.game_name} выгнан из #{user.division.title}"
      user.move
    end
  end

  def move(*ids)
    ids.each do |id|
      user = User.find(id)
      next unless user
      next unless @admin.moderated_divisions.include? user.division
      user.move(session[:division])
      respond_with :message, text: "#{user.game_name} переведен в #{user.division.title}"
    end
  end

  def update_admin(*)
    admins = bot.get_chat_administrators chat_id: @division.telegram_id
    admins.each do |admin|
      user = User.find_by_telegram_id(admin['user']['id'])
      next unless user
      user.update_attributes(type: 'Admin') unless user.admin?
      admin = Admin.find_by_telegram_id(admin['user']['id'])
      admin.moderated_divisions << @division if user.moderated_divisions.include?(@division)
    end
  end

  def walk(*)
    respond_with :message, text: 'Сейчас в путешествие отправиться нельзя. Жди следующего ивента'
    #begin
    #  respond_with :message, text: Journey.start(@user)
    #rescue
    #end
  end

  private

  def set_division
    @division = Division.find_by_telegram_id(update['message']['chat']['id'])
    throw :abort unless @division
  end

  def find_division
    throw :abort unless session[:division]
    @division = Division.find(session[:division])
    throw :abort unless @division
  end

  def set_user
    @user = User.find_by_telegram_id(update['message']['from']['id'])
    logger.error(update['message']['from']['username'].to_s) unless @user
  end

  def set_admin
    @admin = Admin.find_by_telegram_id(update['message']['from']['id'])
    throw :abort unless @admin
  end
end
