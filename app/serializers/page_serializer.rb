class PageSerializer < ActiveModel::Serializer
  attributes :id, :body, :title, :root

  has_many :children, serializer: PageSerializer
end