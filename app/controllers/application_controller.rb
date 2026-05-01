class ApplicationController < ActionController::Base
  include Pagy::Backend

  before_action :authenticate_user!

  helper_method :current_admin?

  def current_admin?
    current_user&.admin?
  end

  private

  def require_admin!
    unless current_admin?
      redirect_to root_path, alert: "You are not authorized to access this page."
    end
  end
end
