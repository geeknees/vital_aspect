class RegisteredUsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: :show

  def index
    @users = User.includes(:organizations, :owned_organizations)
  end

  def show
    @organizations = @user.organizations
    @owned_organizations = @user.owned_organizations
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to registered_users_path, notice: t("users.created_successfully")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
