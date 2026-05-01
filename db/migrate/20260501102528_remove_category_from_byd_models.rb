class RemoveCategoryFromBydModels < ActiveRecord::Migration[8.1]
  def change
    remove_column :byd_models, :category, :integer
  end
end
