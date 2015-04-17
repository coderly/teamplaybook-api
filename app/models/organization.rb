class Organization < ActiveRecord::Base
  validates :subdomain, presence: true, exclusion: { in: Settings.non_organization_subdomains,
    message: "%{value} is not a valid subdomain." }
  validates :name, presence: true
end
