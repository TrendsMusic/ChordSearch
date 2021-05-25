class RemoveKeyFromSongs < ActiveRecord::Migration[5.2]
  def change
    remove_column :songs, :key, :string
  end
end
