class CreateSongs < ActiveRecord::Migration[5.2]
  def change
    create_table :songs do |t|
      t.string :title
      t.string :artist
      t.string :key
      t.string :genre
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
