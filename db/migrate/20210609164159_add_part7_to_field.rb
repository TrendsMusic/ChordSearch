class AddPart7ToField < ActiveRecord::Migration[5.2]
  def change
    add_column :fields, :part7, :string
  end
end
