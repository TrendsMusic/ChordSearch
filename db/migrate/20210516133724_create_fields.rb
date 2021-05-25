class CreateFields < ActiveRecord::Migration[5.2]
  def change
    create_table :fields do |t|
      t.string :part1
      t.string :part2
      t.string :part3
      t.string :part4
      t.references :chord, foreign_key: true

      t.timestamps
    end
  end
end
