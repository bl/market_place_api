class User < ActiveRecord::Base
  before_save :downcase_email

  # valid e-mail regex
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: VALID_EMAIL_REGEX }
  has_secure_password
  validates :password, presence: true, allow_nil: true

  private
    def downcase_email
      self.email = self.email.downcase
    end
end
