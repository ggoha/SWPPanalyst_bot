class TelegramDivisionController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Parsed
  include Showing

  before_action :set_division, only: [:summary, :users]
  before_action :set_user, only: [:me]
  before_action :set_admin, only: [:users, :autopin, :pin_message]

  context_to_action!

  def start(*)
    respond_with :message, text: 'Divisiom'
  end

  def help(*)
    respond_with :message, text: t('.content')
  end

  def message(message)
    #bot.forward_message message_id: message['message_id'], from_chat_id: message['chat']['id'], chat_id: Rails.application.secrets['telegram']['me']
    bot.send_message chat_id: Rails.application.secrets['telegram']['me'], text: parse(message, message_type(message))
  end

  def summary
    #bot.forward_message message_id: message['message_id'], from_chat_id: message['chat']['id'], chat_id: Rails.application.secrets['telegram']['me']
    respond_with :message, text: summary_report, parse_mode: 'Markdown'
  end

  def hashtags
    respond_with :message, text: t('.content')
  end

  def me
    respond_with :message, text: user_report(@user), parse_mode: 'Markdown'
  end

  def autopin(value)
    @admin.moderated_divisions.each {|d| d.update_attributes(autopin: value)}
    respond_with :message, text: "Автопин #{value}"   
  end

  def pin_message(message)
    @admin.moderated_divisions.each {|d| d.update_attributes(message: message)}
    respond_with :message, text: "Сообщения для автопина #{message}"       
  end

  def users
    respond_with :message, text: users_report(@admin.moderated_divisions), parse_mode: 'Markdown'
  end

  private

  def summary_report
    result_str = ''
    battle = @division.company.battles.last
    reports = battle.reports.for_division(@division)
    result_str << "Для #{@division.title} обработано #{reports.count} /battle\n"
    Company.all.each do |company|
      arr = reports.where(broked_company_id: company.id)
      next if arr.empty?
      result_str << "На #{company.title} пошло #{arr.count} человек"
      comrads_percentage = arr.average(:buff)
      result_str << " вместе с #{comrads_percentage.round(0)} %" if comrads_percentage
      sum_money = arr.sum(:money)
      result_str << "\nОни унесли #{arr.sum(:money)}💵\n"
      result_str << "Они вынесли *#{arr.sum(:kill)}* врагов\n"
      sum_score = arr.sum(:score)
      result_str << "Они принесли #{sum_score}🏆 (#{(sum_score.to_f / battle.score * 100).round(2) }%)\n\n"
    end
    sum_score = reports.pluck(:score).inject(0, :+)
    mvp = reports.order(score: :desc).first
    result_str << "🏅 MVP - #{mvp.user.game_name} : #{mvp.score}\n"
    result_str << "Отряд заработал #{sum_score}🏆 (#{(sum_score.to_f / battle.score * 100).round(2) }%)\n"
  end

  def set_division
    @division = Division.find_by_telegram_id(update['message']['chat']['id'])
  end

  def set_user
    @user = User.find_by_telegram_id(update['message']['from']['id'])
  end

  def set_admin
    @admin = Admin.find_by_telegram_id(update['message']['from']['id'])
    throw :abort unless @admin
  end
end
