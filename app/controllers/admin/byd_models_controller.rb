class Admin::BydModelsController < ApplicationController
  before_action :require_admin!
  before_action :set_byd_model, only: [:edit, :update, :destroy]

  def index
    @byd_models = BydModel.sorted
    @pagy, @byd_models = pagy(@byd_models)
  end

  def new
    @byd_model = BydModel.new
  end

  def create
    @byd_model = BydModel.new(byd_model_params)
    if @byd_model.save
      redirect_to admin_byd_models_path, notice: "BYD model created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @byd_model.update(byd_model_params)
      redirect_to admin_byd_models_path, notice: "BYD model updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @byd_model.destroy
      redirect_to admin_byd_models_path, notice: "BYD model deleted."
    else
      redirect_to admin_byd_models_path, alert: "Cannot delete model with existing TARFs."
    end
  end

  private

  def set_byd_model
    @byd_model = BydModel.find(params[:id])
  end

  def byd_model_params
    params.require(:byd_model).permit(:name, :model_code, :active)
  end
end
