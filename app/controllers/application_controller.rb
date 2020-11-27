class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :login_required # Check logined or not for every request
  before_action :current_user # Set current_user if user_id in session
  helper_method :current_user # Set current_user as helper method
  helper_method :reset_flash_message # Set reset_flash_message as helper method
  
  private
  
    # Set current_user if user_id in session
    def current_user
      @current_user ||= User.find_by_id(session[:user_id])
      set_league
    end
    
    # Set league as we only have premier league now
    def set_league
      @league ||= League.first
    end
    
    # Check user_id in session
    def login_required
      unless session[:user_id].present?
        redirect_to login_user_index_path
      end
    end
    
    # Reset old flash messages
    def reset_flash_message
      [:blue_notice, :lightgrey_notice, :success, :danger, :warning, :info,
        :light, :dark].each do |x|
        flash[x] = nil
      end
    end
end
