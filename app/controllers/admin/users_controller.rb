class Admin::UsersController < ApplicationController
  before_action :require_admin!
  before_action :set_user, only: [:show, :edit, :update, :destroy, :resend_confirmation, :toggle_active]

  def index
    @q = params[:search]
    @users = User.includes(:dealer).sorted
    if @q.present?
      @users = @users.where("first_name ILIKE :q OR last_name ILIKE :q OR email ILIKE :q",
                            q: "%#{@q}%")
    end
    @pagy, @users = pagy(@users)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.skip_password_validation = true
    @user.encrypted_password = ""

    if @user.save
      redirect_to admin_users_path, notice: "User created. Confirmation email sent."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "User updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to admin_users_path, alert: "You cannot delete yourself."
    else
      @user.destroy
      redirect_to admin_users_path, notice: "User deleted."
    end
  end

  def resend_confirmation
    @user.send_confirmation_instructions
    redirect_to admin_users_path, notice: "Confirmation email resent to #{@user.email}."
  end

  def toggle_active
    @user.update(active: !@user.active?)
    status = @user.active? ? "activated" : "deactivated"
    redirect_to admin_users_path, notice: "User #{status}."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :role, :dealer_id, :active)
  end
end
