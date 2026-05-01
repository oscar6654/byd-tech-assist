class CreateTarfComments < ActiveRecord::Migration[8.1]
  def change
    create_table :tarf_comments do |t|
      t.references :tarf, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body

      t.timestamps
    end
  end
end
