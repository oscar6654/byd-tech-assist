class Users::PasswordSetupController < ApplicationController
  before_action :ensure_password_setup_needed

  def edit
  end

  def update
    if params[:user][:password].blank?
      current_user.errors.add(:password, "can't be blank")
      render :edit, status: :unprocessable_entity
      return
    end

    if current_user.update(password_params)
      session.delete(:setting_first_password)
      bypass_sign_in(current_user)
      redirect_to root_path, notice: "Password set successfully. Welcome to BYD Tech Assist Center!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def ensure_password_setup_needed
    unless session[:setting_first_password]
      redirect_to root_path
    end
  end
end
