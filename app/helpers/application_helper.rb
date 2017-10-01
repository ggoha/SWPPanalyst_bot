module ApplicationHelper
  SMILE = { 1 => '📯', 2 => '🤖', 3 => '⚡️', 4 => '☂️', 5 => '🎩' }.freeze
  KILL = { 0 => '0⃣️ ', 1 => '1⃣️ ', 2 => '2⃣️ ', 3 => '3⃣️ ', 4 => '4⃣️' }.freeze

  def level(user)
    "🎚#{user.level}".ljust(3, '0')
  end

  def stars(user)
    user.stars ? '⭐️' * user.stars + '🚫' * (3 - user.stars) : '🚫' * 3
  end

  def endurance(user)
    if user.endurance_update_at && user.endurance_update_at >= Battle.last.at
      "🔋#{user.endurance}"
    else
      "🚫#{user.endurance}"
    end.ljust(4, '-')
  end

  def game_name(user)
    user.game_name.delete('[]')
  end

  def user_link(user)
    if user.username
      "[#{game_name(user)}](t.me/#{user.username})"
    else
      game_name(user)
    end
  end

  def report_stats(reports)
    reports.group(:broked_company_id).count.map { |company_id, count| "#{SMILE[company_id]}#{count}" }.join('|')
  end

  def report_kill(reports)
    reports.group(:kill).count.map { |kill, count| "#{KILL[kill]}#{count}" }.join('|')
  end

  def users_report(divisions)
    divisions.each_with_object('') do |division, result|
      result << "*#{division.title}*\n"
      division.users.each_with_object(result) { |user, str| str << user_compact_report(user) }
      result << "\n"
    end
  end

  def user_compact_report(user)
    "#{level(user)} #{stars(user)} 😡#{user.rage} 😔#{user.company.sadness} #{endurance(user)} #{SMILE[user.company_id]}#{user_link(user)}\n"
  end

  def user_report(user)
    result = ''
    result << "#{SMILE[user.company_id]}*#{user.game_name}* #{user.division.title}\n"
    result << "Администратор\n" if user.admin?
    result << "🔨#{user.practice} 🎓#{user.theory} 🐿#{user.cunning} 🐢#{user.wisdom} #{endurance(user)}\n"
    result << "🎚#{user.level} #{stars(user)} 😡#{user.rage} 😔#{user.company.sadness}\n\n"

    result << "📋#{user.reports.count}(#{report_stats(user.reports)})\n"
    result << "⚔️ #{user.reports.sum(:kill)}(#{report_kill(user.reports)})\n"
    result << "💵#{user.reports.sum(:money)}\n"
    result << "🏆#{user.reports.sum(:score)}\n"
    result << "🏅#{user.mvp}\n"
    # TODO
    result << "Обновлен: #{(user.profile_update_at+3.hours).strftime('%H:%M %d-%m-%y')}" if user.profile_update_at
    result
  end

  def mvp_reports(mvp)
    "🏅 MVP - #{mvp.user.game_name} : #{mvp.score}\n"
  end

  def mvp(reports, finally = true)
    mvp = reports.order(score: :desc).first
    if mvp && mvp.score > 0
      mvp.user.reward_mvp if finally
      mvp_reports(mvp)
    end
  end

  def summary_report(division)
    result_str = ''
    return 'Это команда для чатов отрядов' unless division
    battle = division.company.battles.last
    reports = battle.reports.for_division(division)
    result_str << "Для #{division.title} обработано #{reports.count} /battle\n"
    Company.all.each do |company|
      arr = reports.where(broked_company_id: company.id)
      next if arr.empty?
      result_str << "На #{company.title} пошло #{arr.count} человек"
      comrads_percentage = arr.average(:buff)
      result_str << " вместе с #{comrads_percentage.round(0)} %" if comrads_percentage
      result_str << "\nОни унесли #{arr.sum(:money)}💵\n"
      result_str << "Они вынесли *#{arr.sum(:kill)}* врагов\n"
      sum_score = arr.sum(:score)
      result_str << "Они принесли #{sum_score}🏆 (#{(sum_score.to_f / battle.score * 100).round(2)}%)\n\n"
    end
    result_str << mvp(reports, false)
    sum_score = reports.sum(:score)
    result_str << "Отряд заработал #{sum_score}🏆 (#{(sum_score.to_f / battle.score * 100).round(2)}%)\n"
  end

  def company_summary_report(company)
    result_str = ''
    battle = company.battles.last
    result_str << "Для #{company.title} обработано #{battle.reports.count} /battle\n"
    company.divisions.each do |division|
      reports = battle.reports.for_division(division)
      next if reports.empty?
      result_str << "Для #{division.title} обработано #{reports.count} /battle\n"
      Company.all.each do |brocked_company|
        arr = reports.where(broked_company_id: brocked_company.id)
        next if arr.empty?
        result_str << "На #{brocked_company.title} #{arr.count} чел."
        comrads_percentage = arr.average(:buff)
        result_str << " с #{comrads_percentage.round(0)}%." if comrads_percentage
        sum_score = arr.sum(:score)
        result_str << " #{sum_score}🏆 (#{(sum_score.to_f / battle.score * 100).round(2) }%)"
        sum_money = arr.sum(:money)
        total_money = brocked_company.battles.last.money
        result_str << " # {sum_money}💵 (#{(sum_money.to_f / total_money * 100).round(2) }%)\n"
      end
      sum_score = reports.pluck(:score).inject(0, :+)
      result_str << "Отряд заработал #{sum_score}🏆 (#{(sum_score.to_f / battle.score * 100).round(2) }%)\n\n"
    end
    Company.all.each do |brocked_company|
      arr = battle.reports.where(broked_company_id: brocked_company.id)
      comrads_percentage = arr.average(:buff)
      our_money = arr.sum(:money) * 100 / comrads_percentage if comrads_percentage
      total_money = brocked_company.battles.last.money
      result_str << "На #{brocked_company.title} нас было #{(our_money / total_money * 100).round(2)}% нападающих\n" if our_money
    end
    sum_score = battle.reports.pluck(:score).inject(0, :+)
    result_str << "\nВсего обработано #{sum_score}🏆 (#{(sum_score.to_f / battle.score * 100).round(2) }%)"
    result_str
  end

  def current_situation(companies)
    'Текущая грусть: ' + companies.map { |i| "#{i.title} 😔#{i.sadness}" }.join(', ')
  end
end
