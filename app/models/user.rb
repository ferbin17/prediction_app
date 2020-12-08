class User < ApplicationRecord
  attr_accessor :password, :confirm_password, :dont_validate_password
  has_many :predictions
  has_one :prediction_table
  validates_presence_of :email_id, :username
  validates_presence_of :password, if: Proc.new{|user| user.dont_validate_password != false}
  validates_presence_of :confirm_password, if: Proc.new{|user| user.new_record?}
  validate :password_match, if: Proc.new{|user| user.password.present?}
  validates :email_id, uniqueness: { scope: :is_active,
      message: "can have only one active per time." }
  validates :username, uniqueness: { scope: :is_active,
      message: "can have only one active per time." }
  before_save :hash_password, if: Proc.new{|user| user.dont_validate_password != false}
  after_create :create_confirmation_token, if: Proc.new{|user| !user.is_admin}
  scope :active, -> { where(is_active: true) }
  
  def game_week_predictions(game_week_id)
    game_week = GameWeek.find_by_id(game_week_id)
    prediction = predictions.find_by(game_week_id: game_week.id) if game_week
    prediction_scores = prediction.prediction_scores if prediction
    prediction_scores||[]
  end
  # Authentication method for user
  def authenticate
    user = User.active.where("username = ?", self.username).first
    if user.present?
      return user.hashed_password == Digest::SHA1.hexdigest(user.password_salt.to_s + self.password)
    end
    return false
  end
  
  # Check if user account exist or not
  def self.check_user_exists(user)
    found = false
    found = true if User.active.where("username = ?", user.username).present?
    found = true if !found && User.active.where("email_id = ?", user.email_id).present?
    found
  end
  
  # Minimum length if need
  def self.minimum_password_length
    false
  end
  
  def confirm_token
    if self.update(confirmed_at: Time.now, dont_validate_password: false)
      @url = Rails.application.routes.url_helpers.url_for(controller: :user, action: :login)
      UserMailer.with(user: self, url: @url).welcome_mail.deliver_now
    end
  end
  
  def resend_confirmation_mail
    if self.confirmation_token
      @url = Rails.application.routes.url_helpers.url_for(controller: :user, action: :user_confirmation, id: self.confirmation_token)
      UserMailer.with(user: self, url: @url).confirmation_token_mail.deliver_now
    end
  end

  
  private
  
    # Check if password and confirm_password matches
    def password_match
      if password != confirm_password
        errors.add(:password, "doesn't match")
      end
    end
    
    # Hash password before save so that it cant be directly read from Database.
    def hash_password
      self.password_salt =  SecureRandom.base64(8) if self.password_salt == nil
      self.hashed_password = Digest::SHA1.hexdigest(self.password_salt + self.password)
    end
    
    def create_confirmation_token
      tmp_confirmation_token = SecureRandom.base64(32).gsub(/[\, =, \/, +]/, '')
      while User.exists?(confirmation_token: tmp_confirmation_token)
        tmp_confirmation_token = SecureRandom.base64(32).gsub(/[\, =, \/, +]/, '')
      end
      if self.update(confirmation_token: tmp_confirmation_token, dont_validate_password: false)
        @url = Rails.application.routes.url_helpers.url_for(controller: :user, action: :user_confirmation, id: self.confirmation_token)
        UserMailer.with(user: self, url: @url).confirmation_token_mail.deliver_now
      end
    end
end
