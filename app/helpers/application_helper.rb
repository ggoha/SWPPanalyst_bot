module ApplicationHelper
  SMILE = { 1 => '📯', 2 => '🤖', 3 => '⚡️', 4 => '☂️', 5 => '🎩' }.freeze
  KILL = { 0 => '0⃣️ ', 1 => '1⃣️ ', 2 => '2⃣️ ', 3 => '3⃣️ ', 4 => '4⃣️' }.freeze

  def stars(user)
    user.stars ? '⭐️' * user.stars : ''
  end

  def user_link(user)
    if user.username
      "[#{user.game_name.delete('[]')}](t.me/#{user.username})"
    else
      user.game_name
    end
  end

  def report_stats(reports)
    reports.group(:broked_company_id).count.map { |company_id, count| "#{SMILE[company_id]}#{count}" }.join('|')
  end

  def report_kill(reports)
    reports.group(:kill).count.map { |kill, count| "#{KILL[kill]}#{count}" }.join('|')
  end

  def users_report(divisions)
    result = ''
    divisions.each do |division|
      result << "*#{division.title}*\n"
      division.users.each do |user|
        result << "#{SMILE[user.company_id]}#{user_link(user)} 🎚#{user.level} #{stars(user)} 😡#{user.rage} 😔#{user.company.sadness} 🔋#{user.endurance}\n"
      end
      result << "\n"
    end
    result
  end

  def user_report(user)
    result = ''
    result << "#{SMILE[user.company_id]}*#{user.game_name}* #{user.division.title}\n"
    result << "Администратор\n" if user.admin?
    result << "🔨#{user.practice} 🎓#{user.theory} 🐿#{user.cunning} 🐢#{user.wisdom} 🔋#{user.endurance}\n"
    result << "🎚#{user.level} #{stars(user)} 😡#{user.rage} 😔#{user.company.sadness}\n\n"

    result << "📋#{user.reports.count}(#{report_stats(user.reports)})\n"
    result << "⚔️ #{user.reports.sum(:kill)}(#{report_kill(user.reports)})\n"
    result << "💵#{user.reports.sum(:money)}\n"
    result << "🏆#{user.reports.sum(:score)}\n"
    result << "🏅#{user.mvp}\n"
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

  def current_situation(companies)
    'Текущая грусть: ' + companies.map { |i| "#{i.title} 😔#{i.sadness}" }.join(', ')
  end
end
