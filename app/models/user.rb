class User < ApplicationRecord
  include Authentication, PasswordReset
  validates :name, presence: true
  validates :email,
    format: { with: URI::MailTo::EMAIL_REGEXP },
    uniqueness: { case_sensitive: false }

  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships

  before_validation :strip_extranous_spaces

  private

    def strip_extranous_spaces
      self.name = self.name&.strip
      self.email = self.email&.strip
    end

end
