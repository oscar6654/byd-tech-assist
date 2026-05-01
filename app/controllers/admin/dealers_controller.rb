class Admin::DealersController < ApplicationController
  before_action :require_admin!
  before_action :set_dealer, only: [:edit, :update, :destroy]

  def index
    @dealers = Dealer.includes(:dealer_group).sorted
    @pagy, @dealers = pagy(@dealers)
  end

  def new
    @dealer = Dealer.new
  end

  def create
    @dealer = Dealer.new(dealer_params)
    if @dealer.save
      redirect_to admin_dealers_path, notice: "Dealer created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @dealer.update(dealer_params)
      redirect_to admin_dealers_path, notice: "Dealer updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @dealer.destroy
      redirect_to admin_dealers_path, notice: "Dealer deleted."
    else
      redirect_to admin_dealers_path, alert: "Cannot delete dealer with existing TARFs."
    end
  end

  private

  def set_dealer
    @dealer = Dealer.find(params[:id])
  end

  def dealer_params
    params.require(:dealer).permit(:name, :code, :address, :contact_number, :email, :dealer_group_id, :active)
  end
end
