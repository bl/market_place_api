class User < ActiveRecord::Base
  before_create :create_auth_token
  before_save   :downcase_email

  # valid e-mail regex
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: VALID_EMAIL_REGEX }
  has_secure_password
  validates :password, presence: true, allow_nil: true
  validates :auth_token, uniqueness: true

  # generate base64 url-safe string
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # generate bcrypt digest from input string
  # TODO: look into User.digest creating unique digests on each call with same token
  def User.digest(input)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(input, cost: cost)
  end

  # verify authenticated user attribute
  def authenticated?(attribute, token)
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  private

    # set email to downcase
    def downcase_email
      self.email = self.email.downcase
    end

    # set auth token
    def create_auth_token
      begin
        self.auth_token = User.new_token
      end while self.class.exists?(auth_token: auth_token)
    end
end
