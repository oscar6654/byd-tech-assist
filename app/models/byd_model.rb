class BydModel < ApplicationRecord
  has_many :tarfs, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }
  scope :sorted, -> { order(:name) }

  def to_s
    name
  end
end
