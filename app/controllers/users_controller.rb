class UsersController < ApplicationController
  before_action :authenticate_user!

  def edit
    @user = Current.user
  end

  def update
    @user = Current.user
    if @user.update(user_params)
      redirect_to edit_user_path, notice: t("users.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
