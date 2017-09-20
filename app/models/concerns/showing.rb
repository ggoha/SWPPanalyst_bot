module Showing
  extend ActiveSupport::Concern
  SMILE = { 1 => '📯', 2 => '🤖', 3 => '⚡️', 4 => '☂️' , 5 => '🎩' }
  KILL = { 0 => '0⃣️ ', 1 => '1⃣️ ', 2 => '2⃣️ ', 3 => '3⃣️ ', 4 => '4⃣️' }

  def stars(user)
    user.stars ? '⭐️'*user.stars : ''
  end

  def report_stats(reports)
    reports.group(:broked_company_id).count.map{|company_id, count| "#{SMILE[company_id]}#{count}"}.join('|')
  end

  def report_kill(reports)
    reports.group(:kill).count.map{|kill, count| "#{KILL[kill]}#{count}"}.join('|')
  end

  def user(user)
    result = ''
    result << "#{SMILE[user.company_id]}*#{user.game_name}* #{user.division.title}\n"
    result << "🔨#{user.practice} 🎓#{user.theory} 🐿#{user.cunning} 🐢#{user.wisdom}\n"
    result << "🎚#{user.level} #{stars(user)} 😡#{user.rage} 😔#{user.company.sadness}\n\n"

    result << "📋#{user.reports.count}(#{report_stats(user.reports)})\n"
    result << "⚔️ #{user.reports.sum(:kill)}(#{report_kill(user.reports)})\n"
    result << "💵#{user.reports.sum(:money)}\n"
    result << "🏆#{user.reports.sum(:score)}\n"
    result
  end
end
