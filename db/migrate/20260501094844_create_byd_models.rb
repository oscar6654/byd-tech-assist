class CreateBydModels < ActiveRecord::Migration[8.1]
  def change
    create_table :byd_models do |t|
      t.string :name, null: false
      t.string :model_code
      t.integer :category, default: 0, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
