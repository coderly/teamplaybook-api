class Team < ActiveRecord::Base
  validates :subdomain, presence: true, exclusion: { in: Settings.reserved_subdomains,
    message: "%{value} is not a valid subdomain." }
  validates :name, presence: true

  belongs_to :owner, class_name: "User"

  has_one :subscription
  has_one :plan, :through => :subscription

  delegate :name, to: :plan, prefix: true

  def has_stripe_customer?
    stripe_id.present?
  end

  def stripe_user
    Stripe::Customer.retrieve(stripe_id)
  end
end