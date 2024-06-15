class User < ApplicationRecord
  validates :name, presence: true
  validates :email,
    format: { with: URI::MailTo::EMAIL_REGEXP },
    uniqueness: { case_sensitive: false }

  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships

  before_validation :strip_extranous_spaces

  has_secure_password
  validates :password,
    presence: true,
    length: { minimum: 8 }

  has_many :app_sessions

  def self.create_app_session(email:, password:)
    user = User.authenticate_by(email: email, password: password)
    user.app_sessions.create if user.present?
  end

  def authenticate_app_session(app_session_id, token)
    app_sessions.find(app_session_id).authenticate_token(token)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  private

    def strip_extranous_spaces
      self.name = self.name&.strip
      self.email = self.email&.strip
    end

end
