class AddPart6ToField < ActiveRecord::Migration[5.2]
  def change
    add_column :fields, :part6, :string
  end
end
