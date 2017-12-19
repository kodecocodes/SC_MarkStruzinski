class SessionsController < ApplicationController
  def new
  end

  def create
    Rails.logger.debug("Email: #{params[:email]}")
    Rails.logger.debug("Password: #{params[:password]}")
    if params[:email] && params[:password] 
      Rails.logger.debug("Found username and password")
      user = User.new(email: params[:email], password: params[:password])
      log_in(user)
      redirect_to root_url
    else
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_url    
  end
end

