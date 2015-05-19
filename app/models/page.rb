class Page < ActiveRecord::Base
  belongs_to :parent, class_name: "Page"
  has_many :children, :class_name => "Page", :foreign_key => "parent_id"
  belongs_to :team

  def self.for_team(team)
    where(team_id: team.id)
  end
end