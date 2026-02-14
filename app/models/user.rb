class User < ApplicationRecord
  include User::Bot

  # Include default devise modules
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Avatar attachment
  has_one_attached :avatar

  # Associations
  has_many :discussions, dependent: :nullify
  has_many :posts, dependent: :nullify
  has_many :star_ratings, dependent: :destroy
  has_many :admin_actions, foreign_key: :admin_user_id, dependent: :nullify

  # Avatar variant (server-side thumbnail)
  def avatar_thumbnail
    return unless avatar.attached?
    avatar.variant(resize_to_fill: [ 200, 200 ])
  end

  # Validations
  validates :username, presence: true,
            uniqueness: { case_sensitive: false, message: "is already taken" },
            format: { with: /\A[a-zA-Z0-9_-]+\z/, message: "only allows letters, numbers, underscores, and hyphens" },
            length: { minimum: 3, maximum: 20 }

  # Devise: bots don't need email or password
  def email_required?
    !bot?
  end

  def password_required?
    return false if bot?
    !persisted? || password.present? || password_confirmation.present?
  end

  # Check if a soft username conflicts with registered usernames
  def self.soft_username_available?(soft_username)
    return true if soft_username.blank?
    !exists?(username: soft_username)
  end
end
