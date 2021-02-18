class CreateGames < ActiveRecord::Migration[6.1]
  def change
    create_table :games do |t|
      t.text :board
      t.string :winner, limit: 1
      t.timestamps
    end
  end
end
