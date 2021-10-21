class AddPart8ToField < ActiveRecord::Migration[5.2]
  def change
    add_column :fields, :part8, :string
  end
end
