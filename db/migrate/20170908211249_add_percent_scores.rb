class AddPercentScores < ActiveRecord::Migration[5.0]
  def change
    add_column :battles, :percent_score, :float
    Battle.all.group_by(&:at).each do |at, arr|
      sum = arr.pluck(:score).inject(0, :+)
      arr.each do |battle|
        battle.update_attributes(percent_score: battle.score.to_f/sum*100)
      end
    end
  end
end
