class CreateTarfAttachments < ActiveRecord::Migration[8.1]
  def change
    create_table :tarf_attachments do |t|
      t.references :tarf, null: false, foreign_key: true
      t.references :tarf_folder, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :file_name
      t.integer :file_type, default: 0, null: false

      t.timestamps
    end
  end
end
