class CreateDealerGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :dealer_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
