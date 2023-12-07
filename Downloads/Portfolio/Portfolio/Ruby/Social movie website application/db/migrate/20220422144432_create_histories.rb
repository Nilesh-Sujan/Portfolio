class CreateHistories < ActiveRecord::Migration[5.2]
  def change
    create_table :histories do |t|
      t.belongs_to :User, index: true
      t.integer :movie_Id
      t.string :Name
      t.integer :genre
    end
  end
end
