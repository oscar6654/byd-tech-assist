class TarfFolder < ApplicationRecord
  belongs_to :tarf
  has_many :tarf_attachments, dependent: :destroy

  validates :name, presence: true
  validates :name, uniqueness: { scope: :tarf_id }

  scope :sorted, -> { order(:position, :name) }

  before_create :set_position

  private

  def set_position
    self.position ||= (tarf.tarf_folders.maximum(:position) || 0) + 1
  end
end
