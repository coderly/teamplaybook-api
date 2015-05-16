class Team < ActiveRecord::Base
  enum status: [:archived, :active]

  validates :subdomain, presence: true, exclusion: { in: Settings.reserved_subdomains,
    message: "%{value} is not a valid subdomain." }
  validates :name, presence: true

  belongs_to :owner, class_name: "User"
  has_many :team_memberships, dependent: :delete_all
  has_many :members, source: :user, through: :team_memberships

  has_one :subscription
  has_one :plan, :through => :subscription

  delegate :name, to: :plan, prefix: true
  delegate :slug, to: :plan, prefix: true

end
