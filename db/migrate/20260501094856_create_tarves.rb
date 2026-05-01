class CreateTarves < ActiveRecord::Migration[8.1]
  def change
    create_table :tarfs do |t|
      t.string :title, null: false
      t.text :description
      t.text :problem_summary
      t.string :tarf_number, null: false
      t.references :user, null: false, foreign_key: true
      t.references :dealer, null: false, foreign_key: true
      t.references :byd_model, foreign_key: true
      t.integer :category, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.string :keywords
      t.string :part_number
      t.string :part_name
      t.text :fix_description
      t.integer :resolved_by_id
      t.datetime :resolved_at
      t.integer :views_count, default: 0, null: false

      t.timestamps
    end

    add_index :tarfs, :tarf_number, unique: true
    add_index :tarfs, :status
    add_index :tarfs, :category
  end
end
