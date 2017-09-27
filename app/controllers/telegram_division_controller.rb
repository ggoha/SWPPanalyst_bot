class TelegramDivisionController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Parsed

  before_action :set_division, only: [:summary, :users]
  before_action :set_user, only: [:me]
  before_action :set_admin, only: [:users, :divisions, :autopin, :pin_message]
  before_action :find_division, only: [:autopin, :pin_message]

  context_to_action!

  def start(*)
    respond_with :message, text: 'Divisiom'
  end

  def help(*)
    respond_with :message, text: t('.content')
  end

  def message(message)
    type = message_type(message)
    bot.send_message chat_id: Rails.application.secrets['telegram']['me'], text: parse(message, type) if type!=:parse_undefined
  end

  def summary
    respond_with :message, text: summary_report, parse_mode: 'Markdown'
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
      result_str << "Они принесли #{sum_score}🏆 (#{(sum_score.to_f / battle.score * 100).round(2)}%)\n\n"
    end
    sum_score = reports.pluck(:score).inject(0, :+)
    mvp = reports.order(score: :desc).first
    result_str << "🏅 MVP - #{mvp.user.game_name} : #{mvp.score}\n"
    result_str << "Отряд заработал #{sum_score}🏆 (#{(sum_score.to_f / battle.score * 100).round(2)}%)\n"
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
