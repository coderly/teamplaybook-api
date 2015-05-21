class PageSerializer < ActiveModel::Serializer
  attributes :id, :body, :title, :root_node

  has_many :children, serializer: PageSerializer
end