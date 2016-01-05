module Authenticable

  def current_user
    @current_user ||= User.find_by(auth_token: request.headers['Authorization'])
  end

  def current_user?(user)
    user == current_user
  end

  def logged_in?
    !current_user.nil?
  end
end
