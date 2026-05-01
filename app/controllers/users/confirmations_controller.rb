class Users::ConfirmationsController < Devise::ConfirmationsController
  layout "devise"

  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      if resource.encrypted_password.blank?
        sign_in(resource)
        session[:setting_first_password] = true
        redirect_to password_setup_path
      else
        set_flash_message!(:notice, :confirmed)
        redirect_to new_session_path(resource_name)
      end
    else
      render :new, status: :unprocessable_entity
    end
  end
end
