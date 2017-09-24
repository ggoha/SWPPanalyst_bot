module ApplicationHelper
  SMILE = { 1 => '📯', 2 => '🤖', 3 => '⚡️', 4 => '☂️' , 5 => '🎩' }
  KILL = { 0 => '0⃣️ ', 1 => '1⃣️ ', 2 => '2⃣️ ', 3 => '3⃣️ ', 4 => '4⃣️' }

  def stars(user)
    user.stars ? '⭐️' * user.stars : ''
  end

  def user_link(user)
    if user.username
      "[#{user.game_name.delete('[]')}](#{user.username})"
    else
      user.game_name
    end
  end

  def report_stats(reports)
    reports.group(:broked_company_id).count.map{|company_id, count| "#{SMILE[company_id]}#{count}"}.join('|')
  end

  def report_kill(reports)
    reports.group(:kill).count.map{|kill, count| "#{KILL[kill]}#{count}"}.join('|')
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
    result
  end

  def mvp_reports(mvp)
    "🏅 MVP - #{mvp.user.game_name} : #{mvp.score}\n"
  end

  def mvp(reports)
    mvp = reports.order(score: :desc).first
    if mvp && mvp.score > 0
      mvp.user.reward_mvp
      mvp_reports(mvp)
    end
  end

  def current_situation(companies)
    'Текущая грусть: ' + companies.map { |i| "#{i.title} 😔#{i.sadness}" }.join(', ')
  end
end
