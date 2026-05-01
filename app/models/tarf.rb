class Tarf < ApplicationRecord
  include PgSearch::Model

  belongs_to :user
  belongs_to :dealer
  belongs_to :byd_model, optional: true
  belongs_to :resolved_by, class_name: "User", optional: true, foreign_key: :resolved_by_id

  has_many :tarf_folders, dependent: :destroy
  has_many :tarf_attachments, dependent: :destroy
  has_many :tarf_comments, dependent: :destroy

  enum :category, { warranty: 0, general: 1, recall: 2, tsb: 3 }
  enum :status, { open: 0, in_progress: 1, resolved: 2, closed: 3 }

  validates :title, presence: true
  validates :tarf_number, presence: true, uniqueness: true
  validates :description, presence: true

  before_validation :generate_tarf_number, on: :create

  pg_search_scope :search_by_keyword,
    against: { title: "A", problem_summary: "B", keywords: "B", description: "C", part_number: "D", part_name: "D" },
    using: {
      tsearch: { prefix: true, dictionary: "english" }
    }

  scope :sorted, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) if status.present? }
  scope :by_category, ->(category) { where(category: category) if category.present? }
  scope :by_dealer, ->(dealer_id) { where(dealer_id: dealer_id) if dealer_id.present? }
  scope :by_byd_model, ->(byd_model_id) { where(byd_model_id: byd_model_id) if byd_model_id.present? }

  def owned_by?(user)
    self.user_id == user.id
  end

  def can_manage?(user)
    owned_by?(user) || user.admin?
  end

  def resolve!(user:, part_number:, part_name:, fix_description:)
    update!(
      status: :resolved,
      resolved_by: user,
      resolved_at: Time.current,
      part_number: part_number,
      part_name: part_name,
      fix_description: fix_description
    )
  end

  def reopen!
    update!(
      status: :open,
      resolved_by: nil,
      resolved_at: nil
    )
  end

  def increment_views!
    increment!(:views_count)
  end

  private

  def generate_tarf_number
    return if tarf_number.present?
    date_prefix = Date.current.strftime("%Y%m%d")
    last_tarf = Tarf.where("tarf_number LIKE ?", "TARF-#{date_prefix}-%")
                    .order(tarf_number: :desc).first
    if last_tarf
      last_seq = last_tarf.tarf_number.split("-").last.to_i
      self.tarf_number = "TARF-#{date_prefix}-#{(last_seq + 1).to_s.rjust(4, '0')}"
    else
      self.tarf_number = "TARF-#{date_prefix}-0001"
    end
  end
end
