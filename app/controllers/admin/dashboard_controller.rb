class Admin::DashboardController < ApplicationController
  before_action :require_admin!

  def index
    @total_users = User.count
    @total_dealers = Dealer.count
    @total_tarfs = Tarf.count
    @open_tarfs = Tarf.open.count
    @resolved_tarfs = Tarf.resolved.count
    @recent_tarfs = Tarf.sorted.limit(5).includes(:user, :dealer, :byd_model)
  end
end
