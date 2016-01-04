class V1::UsersController < ApplicationController
  respond_to :json

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
    @user = User.find_by id: params[:id]
    if @user
      if @user.update(user_params)
        render json: @user, status: 200, location: @user
      else
        render json: { errors: @user.errors }, status: 422
      end
    else
      render json: { errors: 'not found' }, status: 422
    end
  end

  # TODO: destroy only on properly authenticated user
  def destroy
    @user = User.find_by(id: params[:id])
    if @user
      @user.destroy
      head 204
    else
      render json: { errors: 'not found' }, status: 422
    end
  end

  private

    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation)
    end
end
