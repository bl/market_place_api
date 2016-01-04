class V1::SessionsController < ApplicationController

  def create
    @user = User.find_by(email: params[:session][:email])
    if @user && @user.authenticated?(:password, params[:session][:password])
      # generate new auth_token on valid log-in
      @user.create_auth_token!
      @user.save
      render json: @user, status: 200
    else
      render json: { errors: "Invalid email or password" }, status: 422
    end
  end

  def destroy
    @user = User.find_by(auth_token: params[:id])
    if @user 
      # generate new auth_token to destroy old token
      @user.create_auth_token!
      @user.save
      head 204
    else
      render json: { errors: 'not found' }, status: 422
    end
  end
end
