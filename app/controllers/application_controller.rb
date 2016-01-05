include ActionController::Serialization

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # not needed, as no cookie based sesions used
  #protect_from_forgery with: :exception

  include Authenticable
end
