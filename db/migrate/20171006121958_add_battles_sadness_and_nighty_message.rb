class AddBattlesSadnessAndNightyMessage < ActiveRecord::Migration[5.0]
  def change
    add_column :battles, :current_sadness, :integer
    add_column :divisions, :autopin_nighty, :boolean, default: false
    add_column :divisions, :nighty_message, :string, default: 'Проверьте автосон, ловите биржевиков, приходите завтра на взлом'
  end
end
