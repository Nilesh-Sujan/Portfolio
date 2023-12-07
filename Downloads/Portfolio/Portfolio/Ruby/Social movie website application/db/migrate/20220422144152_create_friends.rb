class CreateFriends < ActiveRecord::Migration[5.2]
  def change
    create_table :friends  do |t|
      t.belongs_to :User, index: true, null: false
      t.integer :User_id, null:false, foreign_key: true
      t.integer :Friend_id, null:false, foreign_key: true
      t.timestamps
    end
    add_index :friends, [:User_id, :Friend_id], unique: true
  end
end
