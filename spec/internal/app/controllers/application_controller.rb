class ApplicationController < ActionController::Base
  # fake current_user method, returns instance of user model
  def current_user
    User.find(session[:user_id])
  end
end