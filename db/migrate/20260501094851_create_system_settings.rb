class CreateSystemSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :system_settings do |t|
      t.string :key, null: false
      t.text :value
      t.string :value_type, default: "string", null: false
      t.string :category, default: "general", null: false
      t.text :description
      t.string :test_status
      t.datetime :last_tested_at

      t.timestamps
    end

    add_index :system_settings, :key, unique: true
    add_index :system_settings, :category
  end
end
