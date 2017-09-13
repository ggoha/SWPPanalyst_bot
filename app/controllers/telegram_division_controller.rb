class TelegramDivisionController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  include Parsed

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

  def summary
    respond_with :message, text: summary_report, parse_mode: 'Markdown'
  end

  private

  def summary_report
    result_str = ''
    battle = Company.our.battles.last
    result_str << "Обработано #{battle.reports.count} /battle\n" 
    battle.reports.group_by(&:broked_company_id).each do |company_id, arr|
      company = Company.find(company_id)
      result_str << "На #{company.title} пошло #{arr.count} человек\n"
      sum_money = arr.pluck(:money).inject(0, :+)
      result_str << "Они унесли #{sum_money}💵\n"
      sum_kill = arr.pluck(:kill).inject(0, :+)
      result_str << "Они вынесли *#{sum_kill}* врагов\n"
      sum_score = arr.pluck(:score).inject(0, :+)
      result_str << "Они принесли #{sum_score}🏆 (#{(sum_score.to_f / battle.score * 100).round(2) }%)\n\n"
    end
    sum_score = battle.reports.pluck(:score).inject(0, :+)
    mvp = battle.reports.order(score: :desc).first
    result_str << "MVP - [#{mvp.user.game_name}](@#{mvp.user.username}) : #{mvp.score}\n"
    result_str << "Отряд заработал #{sum_score}🏆 (#{(sum_score.to_f / battle.score * 100).round(2) }%)\n"
  end
end
