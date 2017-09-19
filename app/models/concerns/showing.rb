module Showing
  extend ActiveSupport::Concern
  def stars(user)
    '⭐️'*user.stars
  end

  def user(user)
    result = ''
    result << "#{user.game_name} #{user.division.title}\n"
    result << "🔨#{user.practice} 🎓#{user.theory} 🐿#{user.cunning} 🐢#{user.wisdom}\n"
    result << "🎚#{user.level} #{stars(user)} 😡#{user.rage} 😔#{user.company.sadness}\n\n"

    result << "⚔️ #{user.reports.count}\n"
    result << "💵#{user.reports.sum(:money)}\n"
    result << "🏆#{user.reports.sum(:score)}\n"
    result
  end
end
