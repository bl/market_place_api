class V1::UsersController < ApplicationController
  respond_to :json

  before_action :logged_in_user,  only: [:update, :destroy]
  before_action :correct_user,    only: [:update, :destroy]
  #TODO: admin_user on destroy action

  def show
    @user = User.find_by(id: params[:id])
    render json: @user
  end

  def create
    @user = User.new user_params
    if @user.save
      render json: @user, status: 201, location: @user
    else
      render json: { errors: @user.errors }, status: 422
    end
  end

  def update
    if @user.update(user_params)
      render json: @user, status: 200, location: @user
    else
      render json: { errors: @user.errors }, status: 422
    end
  end

  # TODO: destroy only on properly authenticated user
  def destroy
    @user = User.find params[:id]
    @user.destroy
    head 204
  end

  private

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
end
