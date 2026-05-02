class TarfAttachment < ApplicationRecord
  belongs_to :tarf
  belongs_to :tarf_folder, optional: true
  belongs_to :user

  has_one_attached :file

  enum :file_type, { image: 0, video: 1, document: 2 }

  validates :file, presence: true

  before_validation :detect_file_type, if: -> { file.attached? }
  before_validation :set_file_name, if: -> { file.attached? && file_name.blank? }
  after_create_commit :enqueue_video_compression, if: :video?

  scope :images, -> { where(file_type: :image) }
  scope :videos, -> { where(file_type: :video) }
  scope :documents, -> { where(file_type: :document) }

  IMAGE_CONTENT_TYPES = %w[image/jpeg image/png image/gif image/webp].freeze
  VIDEO_CONTENT_TYPES = %w[video/mp4 video/webm video/quicktime video/x-msvideo video/x-matroska video/x-ms-wmv video/avi video/ogg].freeze
  DOCUMENT_CONTENT_TYPES = %w[application/pdf application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet].freeze

  BROWSER_PLAYABLE_VIDEO_TYPES = %w[video/mp4 video/webm video/ogg].freeze

  def browser_playable?
    video? && BROWSER_PLAYABLE_VIDEO_TYPES.include?(file.content_type)
  end

  def can_delete?(current_user)
    tarf.owned_by?(current_user) || current_user.admin?
  end

  private

  def detect_file_type
    content_type = file.content_type
    self.file_type = if IMAGE_CONTENT_TYPES.include?(content_type)
      :image
    elsif VIDEO_CONTENT_TYPES.include?(content_type)
      :video
    else
      :document
    end
  end

  def set_file_name
    self.file_name = file.filename.to_s
  end

  def enqueue_video_compression
    VideoCompressionJob.perform_later(id)
  end
end
