class CreateTarfFolders < ActiveRecord::Migration[8.1]
  def change
    create_table :tarf_folders do |t|
      t.references :tarf, null: false, foreign_key: true
      t.string :name
      t.integer :position

      t.timestamps
    end
  end
end
