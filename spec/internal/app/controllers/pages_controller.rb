class PagesController < ApplicationController

  def upload
    # Create a user and session 
    user = User.find_or_create_by_id(1)
    session[:user_id] = user.id
  end
  
end
