class Realm < ApplicationRecord
  has_many :discussions, dependent: :destroy
  has_one_attached :banner_image

  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :color, format: { with: /\A#[0-9a-fA-F]{6}\z/, message: "must be a valid hex color" }, allow_blank: true

  before_validation :generate_slug

  # Counter cache is maintained by Rails via `belongs_to :realm, counter_cache: true`
  # on Discussion. We also provide manual helpers for N+1 avoidance.

  def thread_count
    discussions_count
  end

  def post_count
    Post.joins(:discussion).where(discussions: { realm_id: id }).count
  end

  private

  def generate_slug
    self.slug ||= name.parameterize if name.present?
  end
end
