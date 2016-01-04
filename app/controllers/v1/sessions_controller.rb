class V1::SessionsController < ApplicationController
  def create
    @user = User.find_by(email: params[:session][:email])
    if @user && @user.authenticated?(:password, params[:session][:password])
      render json: @user, status: 200
    else
      render json: { errors: "Invalid email or password" }, status: 422
    end
  end

  def destroy
  end
end
