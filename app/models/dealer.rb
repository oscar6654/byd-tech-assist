class Dealer < ApplicationRecord
  belongs_to :dealer_group, optional: true
  has_many :users, dependent: :nullify
  has_many :tarfs, dependent: :restrict_with_error

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }
  scope :sorted, -> { order(:name) }

  def to_s
    name
  end

  def display_name
    "#{name} (#{code})"
  end
end
