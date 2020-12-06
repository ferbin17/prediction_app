class UserController < ApplicationController
  skip_before_action :login_required, only: [:login, :sign_up, :user_confirmation] # Skip login checked for login page and signup page
  before_action :redirect_to_root, only: [:login, :sign_up] # Redirect to root if logined and accessing login or signup

  def home
    @current_game_week = @league.current_game_week
    @prediction = @current_user.predictions.find_by(game_week_id: @current_game_week.id)
    @prediction_scores = @prediction.prediction_scores if @prediction
  end
  
  # User login
  def login
    @user = User.new
    if request.post?
      # Build (does save) new user with given params and authenticate eamil and password
      @user = User.new(user_params)
      if @user.authenticate
        # If authenticated, session and cookies are set for later usage
        user = User.active.where("username = binary(?)", @user.username).first
        if user.confirmed_at.present?
          set_time_zone_and_sign_in_count(user)
          session[:user_id] = cookies.signed[:user_id] = user.id
          reset_flash_message
          # Setting just_login params for inform login
          session[:just_logined] = true
          # Redirect back to last page if present else to root page
          redirect_to (session[:back_path].present? ? session.delete(:back_path) : root_path)
        else
          reset_flash_message
          flash[:danger] = t(:please_confirm_your_mail_before_logining_check_mail_confirmation_link)
          redirect_to action: :login
        end
      else
        # Reset old flash message and add new one for wrong credentials and render login page once more
        reset_flash_message
        flash[:danger] = t(:wrong_credentials)
        redirect_to action: :login
      end
    end
  end
  
  def sign_up
    # Reset old flash message
    reset_flash_message
    @user = User.new
    if request.post?
      # Build (not save) new user and check if email_id also present
      @user = User.new(user_params) 
      unless User.check_user_exists(@user)
        # If email_id not present, save user and set session and cookies ofr later use
        if @user.save
          flash[:danger] = t(:please_confirm_your_mail_before_logining_check_mail_confirmation_link)
          redirect_to :root
        else
          # Render sign up page once more any errors
          render action: :sign_up
        end
      else
        # Add new flash messages if any params missing and errors
        flash[:danger] = "#{t(:account_exist)}. <br>#{view_context.link_to t(:click_here_to_login), login_user_index_path} or #{view_context.link_to t(:click_hereh_to_reset_password), forgot_password_user_index_path}"
        redirect_to action: :sign_up
      end
    end
  end

  def logout
    # Reset user session and cookies
    reset_session
    redirect_to :root
  end
  
  def user_confirmation
    reset_flash_message
    if params[:id].present?
      user = User.find_by(confirmation_token: params[:id])
      user.confirm_token if user.present?
    end
    flash[:danger] = "Invalid confirmation token" unless user.present?
    redirect_to action: :login
  end
  
  private

    # Fetches user params
    def user_params
      params.require(:user).permit(:password, :confirm_password, :email_id, :username)
    end
    
    # Reset session and cookies
    def reset_session
      session[:time_zone] = session[:user_id] = cookies.signed[:user_id] = nil
    end
    
    # Redirect to root if logined and accessing login or signup
    def redirect_to_root
      if session[:user_id].present?
        redirect_to :root
      end
    end
    
    def set_time_zone_and_sign_in_count(user)
      time_zone = params.dig(:user, :time_zone)
      hash = {sign_in_count: user.sign_in_count.to_i + 1, dont_validate_password: false}
      hash = hash.merge({time_zone: ActiveSupport::TimeZone::MAPPING.key(time_zone)}) if time_zone.present?
      user.update(hash)
      session[:time_zone] = user.time_zone
    end
end
