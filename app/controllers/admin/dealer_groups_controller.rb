class Admin::DealerGroupsController < ApplicationController
  before_action :require_admin!
  before_action :set_dealer_group, only: [:edit, :update, :destroy]

  def index
    @dealer_groups = DealerGroup.sorted
    @pagy, @dealer_groups = pagy(@dealer_groups)
  end

  def new
    @dealer_group = DealerGroup.new
  end

  def create
    @dealer_group = DealerGroup.new(dealer_group_params)
    if @dealer_group.save
      redirect_to admin_dealer_groups_path, notice: "Dealer group created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @dealer_group.update(dealer_group_params)
      redirect_to admin_dealer_groups_path, notice: "Dealer group updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @dealer_group.destroy
    redirect_to admin_dealer_groups_path, notice: "Dealer group deleted."
  end

  private

  def set_dealer_group
    @dealer_group = DealerGroup.find(params[:id])
  end

  def dealer_group_params
    params.require(:dealer_group).permit(:name)
  end
end
