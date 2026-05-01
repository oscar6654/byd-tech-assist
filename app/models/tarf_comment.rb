class TarfComment < ApplicationRecord
  belongs_to :tarf
  belongs_to :user

  has_many_attached :attachments

  validates :body, presence: true

  scope :sorted, -> { order(created_at: :desc) }
end
