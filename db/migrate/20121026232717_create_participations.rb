class CreateParticipations < ActiveRecord::Migration
  def change
    create_table :participations do |t|
      t.integer :user_id
      t.integer :micropost_id

      t.timestamps
    end
    add_index :participations, :user_id
    add_index :participations, :micropost_id
    add_index :participations, [:user_id, :micropost_id], unique: true
  end
end
