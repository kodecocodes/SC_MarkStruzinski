module SessionsHelper
    def log_in(user)
        Rails.logger.debug("Logging in")
        Rails.logger.debug("User email: #{user.email}")
        Rails.logger.debug("User password: #{user.password}")

        session[:email] = user.email
        session[:password] = user.password

        Rails.logger.debug("Session email: #{session[:email]}")
        Rails.logger.debug("Session password: #{session[:password]}")
    end
    
    def current_user
        if !session[:email].nil? && !session[:password].nil?
            @current_user = User.new(email: session[:email], password: session[:password])
        else 
            @current_user = nil
        end
    # @current_user ||= User.find_by(id: session[:user_id])
    end
    
    def logged_in?
        !current_user.nil?
    end
    
    def log_out
        session.delete(:email)
        session.delete(:password)
        @current_user = nil
    end
end
