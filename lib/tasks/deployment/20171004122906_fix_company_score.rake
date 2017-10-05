namespace :after_party do
  desc 'Deployment task: fix_company_score'
  task fix_company_score: :environment do
    scores = [3894705, 4720601, 4972018, 5202213, 6571106]
    Company.all.each_with_index do |company, i|
      company.update_attributes(score: scores[i])
      summary_score = scores[i]
      company.battles.reverse.each do |battle|
        battle.update_attributes(summary_score: summary_score)
        summary_score -= battle.score
    end
    # Update task as completed.  If you remove the line below, the task will
    # run with every deploy (or every time you call after_party:run).
    AfterParty::TaskRecord.create version: '20171004122906'
  end
end
