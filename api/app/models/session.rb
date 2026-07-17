# frozen_string_literal: true

class Session < ApplicationRecord
  include TenantScoped

  STATUSES   = %w[pending active ended failed].freeze
  END_REASONS = %w[manual_candidate manual_assessor all_covered time_ceiling error].freeze

  belongs_to :assessment
  has_many :transcript_turns, dependent: :destroy
  has_many :coverage_maps, dependent: :destroy
  has_one  :portfolio, dependent: :destroy

  validates :invite_token, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUSES }
  validates :end_reason, inclusion: { in: END_REASONS }, allow_nil: true

  before_validation :generate_invite_token, on: :create

  scope :active,  -> { where(status: 'active') }
  scope :pending, -> { where(status: 'pending') }
  scope :ended,   -> { where(status: 'ended') }

  def active?  = status == 'active'
  def ended?   = status == 'ended'
  def pending? = status == 'pending'

  def invite_url
    base = ENV['WEB_BASE_URL'].presence ||
           local_web_base_url ||
           ENV.fetch('APP_BASE_URL', 'http://localhost:5173')
    "#{base}/interview/#{invite_token}"
  end

  private

  def local_web_base_url
    app_base = ENV['APP_BASE_URL'].to_s
    return unless app_base.match?(/\Ahttps?:\/\/(localhost|127\.0\.0\.1):3001\z/)

    app_base.sub(/:3001\z/, ':5173')
  end

  def generate_invite_token
    self.invite_token ||= SecureRandom.hex(32)
  end
end
