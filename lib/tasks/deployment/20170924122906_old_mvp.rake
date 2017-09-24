namespace :after_party do
  desc 'Deployment task: old_mvp'
  task old_mvp: :environment do
    puts "Running deploy task 'old_mvp'"

    # Put your task implementation HERE.
    Company.our.battles.each do |battle|
      Division.all.each do |division|
        mvp = battle.reports.for_division(division).order(score: :desc).first
        mvp.user.reward_mvp if mvp && mvp.user.score > 0
      end
    end
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20170924122906'
  end
end
