class Subscription < ActiveRecord::Base
  belongs_to :team
  belongs_to :plan
end
