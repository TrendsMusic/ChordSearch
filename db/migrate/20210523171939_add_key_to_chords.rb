class AddKeyToChords < ActiveRecord::Migration[5.2]
  def change
    add_column :chords, :key, :string
  end
end
