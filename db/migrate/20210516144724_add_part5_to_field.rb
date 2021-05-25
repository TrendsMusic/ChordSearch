class AddPart5ToField < ActiveRecord::Migration[5.2]
  def change
    add_column :fields, :part5, :string
  end
end
