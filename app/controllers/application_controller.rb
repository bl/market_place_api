include ActionController::Serialization

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # not needed, as no cookie based sesions used
  #protect_from_forgery with: :exception

  include Authenticable

  private

    def logged_in_user
      render json: { errors: "Not authenticated" }, 
             status: :unauthorized unless logged_in?
    end

    # TODO: refactor: separate implementation for products & users controller
    def correct_user
      user_id = params[:id] || params[:user_id]
      @user ||= User.find_by id: user_id
      render json: { errors: "Incorrect user" }, 
             status: 403 unless !@user.nil? && current_user?(@user)
    end

end
