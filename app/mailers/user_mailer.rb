class UserMailer < ApplicationMailer
  def welcome_mail
    @user = params[:user]
    @url = params[:url]
    mail(to: @user.email_id, subject: "Welcome to PL Prediction App")
  end
  
  def confirmation_token_mail
    @user = params[:user]
    @url = params[:url]
    mail(to: @user.email_id, subject: "PL Prediction App Confirmation")
    @user.update(confirmation_sent_at: Time.now, dont_validate_password: false)
  end
end
