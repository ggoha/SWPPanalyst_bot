module ApplicationHelper
  SMILE = { 1 => '📯', 2 => '🤖', 3 => '⚡️', 4 => '☂️', 5 => '🎩' }.freeze
  KILL = { 0 => '0⃣️ ', 1 => '1⃣️ ', 2 => '2⃣️ ', 3 => '3⃣️ ', 4 => '4⃣️' }.freeze

  def idv(user)
    "🆔#{user.id}".ljust(4, '#')
  end

  def level(user)
    "🎚#{user.level}".ljust(3, '#')
  end

  def stars(user)
    user.stars ? '⭐️' * user.stars + '🚫' * (3 - user.stars) : '🚫' * 3
  end

  def last_update(user)
    '⏱' + (user.profile_update_at ? user.profile_update_at.strftime('%H-%d') : '##-##')
  end

  def endurance(user)
    if user.endurance_update_at && user.endurance_update_at >= Battle.last.at
      "🔋#{user.endurance}"
    else
      "🚫#{user.endurance}"
    end.ljust(4, '#')
  end

  def game_name(user)
    user.game_name.delete('[_]')
  end

  def user_link(user)
    user.username ? "[#{game_name(user)}](t.me/#{user.username})" : game_name(user)
  end

  def report_stats(reports)
    reports.group(:broked_company_id).count.map { |company_id, count| "#{SMILE[company_id]}#{count}" }.join('|')
  end

  def report_kill(reports)
    reports.group(:kill).count.map { |kill, count| "#{KILL[kill]}#{count}" }.join('|')
  end

  def short_achivment_report(achivment, user)
    if achivment.public
      user.achivments.include?(achivment) ? achivment.icon : '❔'
    else
      user.achivments.include?(achivment) ? achivment.icon : ''
    end
  end

  def achivment_report(achivment, user)
    if achivment.public?
      if user.achivments.include? achivment
        str = "#{achivment.icon}#{achivment.title} "
        str << "- #{achivment.description} " if achivment.show?
        str << "#{achivment.percentage.round(2)}%\n"
      else
        "❔\n"
      end
    else
      if user.achivments.include? achivment
        "#{achivment.icon}#{achivment.title} - #{achivment.description} #{achivment.percentage.round(2)}%\n"
      else
        ''
      end
    end
  end

  def achivments_report(user, detailed = true)
    Achivment.all.each_with_object('') do |achivment, result|
      result << (detailed ? achivment_report(achivment, user) : short_achivment_report(achivment, user))
    end << "\n"
  end

  def user_battle_report(user, battle)
    result = ''
    report = battle.reports.where(user_id: user.id).first
    return '#{battle.at.hour} - ' unless report
    result << "#{battle.at.hour} - #{report.score}🏆 #{report.money}💵 #{SMILE[report.broked_company_id]}"
  end

  def history_report(user)
    result = "Результаты битв\n"
    result << "Вчера:\n"
    user.company.battles.yesterday.each do |battle|
      result << user_battle_report(user, battle)
    end << "\n"
    result << "Сегодня:\n"
    user.company.battles.day.each do |battle|
      result << user_battle_report(user, battle)
    end
  end

  def users_report(divisions)
    divisions.each_with_object([]) do |division, result|
      result_str = "*#{division.title}*\n"
      division.users.each_with_object(result_str) { |user, str| str << user_compact_report(user) }
      result_str << "\n"
      result << result_str
    end
  end

  def user_compact_report(user)
    "#{idv(user)} #{level(user)} #{stars(user)} 😡#{user.rage} 😔#{user.company.sadness} #{endurance(user)} " \
      "#{last_update(user)} #{SMILE[user.company_id]}#{user_link(user)}\n"
  end

  def user_report(user)
    result = ''
    result << "#{SMILE[user.company_id]}*#{game_name(user)}* #{user.division.title}\n"
    result << "Администратор\n" if user.admin?
    result << "🔨#{user.practice} 🎓#{user.theory} 🐿#{user.cunning} 🐢#{user.wisdom} #{endurance(user)}\n"
    result << "🎚#{user.level} #{stars(user)} 😡#{user.rage} 😔#{user.company.sadness}\n\n"
    result << "📋#{user.reports.count}(#{report_stats(user.reports)})\n"
    result << "⚔️ #{user.reports.sum(:kill)}(#{report_kill(user.reports)})\n"
    result << "💵#{user.reports.sum(:money)}\n"
    result << "🏆#{user.reports.sum(:score)}\n"
    result << "🏅#{user.mvp}\n"
    result << "Обновлен: #{(user.profile_update_at + 3.hours).strftime('%H:%M %d-%m-%y')}\n" if user.profile_update_at
    result << achivments_report(user, false)
    result
  end

  def mvp_reports(mvp)
    "🏅 MVP - #{game_name(mvp.user)} : #{mvp.score}\n"
  end

  def mvp(reports, finally = true)
    mvp = reports.order(score: :desc).first
    if mvp && mvp.score.positive?
      mvp.user.reward_mvp if finally
      mvp_reports(mvp)
    else
      ''
    end
  end

  def division_report(division, detailed_view = false)
    result_str = ''
    battle = division.company.battles.last
    reports = battle.reports.for_division(division)
    return '' if reports.empty? && !detailed_view
    result_str << "Для #{division.title} обработано #{reports.count} /battle\n"
    Company.all.each do |brocked_company|
      arr = reports.where(broked_company_id: brocked_company.id)
      next if arr.empty?
      result_str << "На #{brocked_company.title} #{arr.count} чел."
      comrads_percentage = arr.average(:buff)
      result_str << " с #{comrads_percentage.round(0)}%." if comrads_percentage
      result_str << "\nОни унесли #{arr.sum(:money)}💵\n" if detailed_view
      result_str << "Они вынесли *#{arr.sum(:kill)}* врагов\n" if detailed_view
      sum_score = arr.sum(:score)
      result_str << 'Они принесли' if detailed_view
      result_str << " #{sum_score}🏆 (#{(sum_score.to_f / battle.score * 100).round(2)}%)\n"
      result_str << "\n" if detailed_view
    end
    mvp = mvp(reports, false) if detailed_view
    result_str << mvp unless mvp.blank?
    sum_score = reports.sum(:score)
    result_str << "Отряд заработал #{sum_score}🏆 (#{(sum_score.to_f / battle.score * 100).round(2)}%)\n\n"
  end

  def summary_report(division)
    return 'Это команда для чатов отрядов' unless division
    division_report(division, true)
  end

  def company_summary_report(company)
    result_str = ''
    battle = company.battles.last
    sum_score = battle.reports.sum(:score)
    return 'sum score 0' if sum_score == 0
    total_count_people = battle.reports.count * battle.score / sum_score.to_f
    result_str << "Для #{company.title} обработано #{battle.reports.count} /battle. Должно быть #{total_count_people.to_i}\n"
    company.divisions.each_with_object(result_str) { |division, str| str << division_report(division) }
    Company.all.each do |brocked_company|
      arr = battle.reports.where(broked_company_id: brocked_company.id)
      next if arr.empty?
      if arr.average(:buff)
        total_count_people_direction = total_count_people * arr.average(:buff) / 100
        # total_money_direction = arr.sum(:money) * total_count_people_direction / arr.count
        # total_money = brocked_company.battles.last.money
        result_str << "На #{brocked_company.title} пошло #{arr.count}/#{total_count_people_direction.to_i} c #{arr.average(:buff).round(2)}%\n"
      else
        result_str << "На #{brocked_company.title} пошло #{arr.count}/NaN c #NaN%\n"
      end
    end
    sum_score = battle.reports.sum(:score)
    result_str << "\nВсего обработано #{sum_score}🏆 (#{(sum_score.to_f / battle.score * 100).round(2)}%)\n"
  end

  def current_situation(companies)
    'Текущая грусть: ' + companies.map { |i| "#{i.title} 😔#{i.sadness}" }.join(', ')
  end

  def current_situation_with_monster
    "🎃На данный момент у👹#{Monster.take.title} осталось\n" \
    "👻у первой головы - #{Monster.take.hp2}💚\n" \
    "💀у второй головы - #{Monster.take.hp3}💛\n" \
    "☠️у третьей головы - #{Monster.take.hp4}💜\n" \
    "👽у четвертой головы - #{Monster.take.hp5}🖤\n" 
  end
end
