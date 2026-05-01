class Users::SessionsController < Devise::SessionsController
  layout "devise"

  def create
    self.resource = warden.authenticate!(auth_options)
    if resource.active?
      set_flash_message!(:notice, :signed_in)
      sign_in(resource_name, resource)
      respond_with resource, location: after_sign_in_path_for(resource)
    else
      sign_out resource
      flash[:alert] = "Your account has been deactivated. Please contact the administrator."
      redirect_to new_user_session_path
    end
  end

  protected

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_root_path
    else
      root_path
    end
  end
end
