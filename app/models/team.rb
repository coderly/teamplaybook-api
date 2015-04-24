class Team < ActiveRecord::Base
  validates :subdomain, presence: true, exclusion: { in: Settings.non_team_subdomains,
    message: "%{value} is not a valid subdomain." }
  validates :name, presence: true

  belongs_to :owner, class_name: "User"
end