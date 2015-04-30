class PlanSerializer < ActiveModel::Serializer
  attributes :id, :slug, :name, :trial_period_days
end