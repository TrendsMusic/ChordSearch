class CreateChords < ActiveRecord::Migration[5.2]
  def change
    create_table :chords do |t|
      t.string :section_numbar
      t.string :content
      t.references :song, foreign_key: true

      t.timestamps
    end
  end
end
