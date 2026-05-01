class CreateDealers < ActiveRecord::Migration[8.1]
  def change
    create_table :dealers do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.text :address
      t.string :contact_number
      t.string :email
      t.references :dealer_group, foreign_key: true
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    add_index :dealers, :code, unique: true
  end
end
