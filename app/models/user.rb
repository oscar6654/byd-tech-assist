class User < ApplicationRecord
  devise :database_authenticatable, :confirmable,
         :recoverable, :rememberable, :validatable, :trackable

  belongs_to :dealer, optional: true
  has_many :tarfs, dependent: :restrict_with_error
  has_many :tarf_comments, dependent: :destroy
  has_many :tarf_attachments, dependent: :restrict_with_error

  enum :role, { dealer_user: 0, admin: 1 }

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :dealer, presence: true, unless: :admin?

  scope :active, -> { where(active: true) }
  scope :sorted, -> { order(:last_name, :first_name) }

  attr_accessor :skip_password_validation

  def full_name
    "#{first_name} #{last_name}"
  end

  def to_s
    full_name
  end

  def active_for_authentication?
    super && active?
  end

  def inactive_message
    active? ? super : :deactivated
  end

  protected

  def password_required?
    return false if skip_password_validation
    super
  end
end
