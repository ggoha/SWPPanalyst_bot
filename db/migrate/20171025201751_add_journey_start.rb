class AddJourneyStart < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :star_journey_at, :datetime
  end
end
