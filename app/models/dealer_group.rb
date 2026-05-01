class DealerGroup < ApplicationRecord
  has_many :dealers, dependent: :nullify

  validates :name, presence: true, uniqueness: true

  scope :sorted, -> { order(:name) }

  def to_s
    name
  end
end
