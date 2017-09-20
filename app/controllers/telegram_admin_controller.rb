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
      respond_with :message, text: summary_report, parse_mode: 'Markdown'
    else
      bot.send_message chat_id: Rails.application.secrets['telegram']['me'], text: 'неправильный канал'
    end
  end

  private

  def summary_report
    result_str = ''
    company = Company.our
    battle = company.battles.last
    result_str << "Для #{company.title} обработано #{battle.reports.count} /battle\n"
    company.divisions.each do |division|
      reports = battle.reports.for_division(division)
      result_str << "Для #{division.title} обработано #{reports.count} /battle\n"
      Company.all.each do |company|
        arr = reports.where(broked_company_id: company.id)
        next if arr.empty?
        result_str << "На #{company.title} #{arr.count} человек"
        comrads_percentage = arr.average(:buff)
        result_str << " вместе с #{comrads_percentage.round(0)}%." if comrads_percentage
        sum_score = arr.sum(:score)
        result_str << " заработали #{sum_score}🏆 (#{(sum_score.to_f / battle.score * 100).round(2) }%)\n"
      end
      sum_score = reports.pluck(:score).inject(0, :+)
      result_str << "Отряд заработал #{sum_score}🏆 (#{(sum_score.to_f / battle.score * 100).round(2) }%)\n\n"
    end
    sum_score = battle.reports.pluck(:score).inject(0, :+)
    result_str << "\nВсего обработано #{sum_score}🏆 (#{(sum_score.to_f / battle.score * 100).round(2) }%)"
    result_str
  end
end
