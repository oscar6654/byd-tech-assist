class VideoCompressionJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :polynomially_longer, attempts: 3

  # Compresses video attachments using FFmpeg after upload.
  # Downloads original from S3, re-encodes at 720p/1.5Mbps, replaces the blob.
  def perform(tarf_attachment_id)
    attachment = TarfAttachment.find_by(id: tarf_attachment_id)
    return unless attachment&.video? && attachment.file.attached?

    blob = attachment.file.blob
    original_size = blob.byte_size
    return if original_size < 5.megabytes # skip small videos

    unless ffmpeg_available?
      Rails.logger.warn "VideoCompressionJob: ffmpeg not found, skipping compression"
      return
    end

    Dir.mktmpdir("video_compress") do |tmpdir|
      input_path = File.join(tmpdir, "input_#{blob.filename}")
      output_path = File.join(tmpdir, "compressed.mp4")

      File.open(input_path, "wb") { |f| blob.download { |chunk| f.write(chunk) } }

      success = run_ffmpeg(input_path, output_path)

      if success && File.exist?(output_path)
        compressed_size = File.size(output_path)

        if compressed_size < original_size * 0.85
          savings_pct = ((1 - compressed_size.to_f / original_size) * 100).round
          Rails.logger.info "VideoCompressionJob: #{blob.filename} compressed #{format_size(original_size)} → #{format_size(compressed_size)} (#{savings_pct}% smaller)"

          attachment.file.attach(
            io: File.open(output_path),
            filename: blob.filename.to_s.sub(/\.[^.]+$/, ".mp4"),
            content_type: "video/mp4"
          )

          blob.purge_later
        else
          Rails.logger.info "VideoCompressionJob: #{blob.filename} — compression didn't save enough (#{format_size(original_size)} → #{format_size(compressed_size)}), keeping original"
        end
      else
        Rails.logger.warn "VideoCompressionJob: ffmpeg failed for #{blob.filename}"
      end
    end
  end

  private

  def run_ffmpeg(input, output)
    cmd = [
      "ffmpeg", "-y", "-i", input,
      "-vf", "scale='min(1280,iw)':'-2'",    # max 720p width, auto height (even)
      "-c:v", "libx264",                       # H.264 codec (universal playback)
      "-preset", "medium",                      # balance speed vs compression
      "-crf", "28",                             # constant quality (23=default, 28=smaller)
      "-c:a", "aac", "-b:a", "128k",           # AAC audio at 128kbps
      "-movflags", "+faststart",                # streaming-friendly MP4
      "-threads", "2",                          # limit CPU usage
      "-loglevel", "error",
      output
    ]

    Rails.logger.info "VideoCompressionJob: Running ffmpeg for #{File.basename(input)} (#{format_size(File.size(input))})"
    system(*cmd)
  end

  def ffmpeg_available?
    system("which ffmpeg > /dev/null 2>&1")
  end

  def format_size(bytes)
    if bytes < 1024
      "#{bytes}B"
    elsif bytes < 1024 * 1024
      "#{(bytes / 1024.0).round}KB"
    else
      "#{(bytes / 1024.0 / 1024.0).round(1)}MB"
    end
  end
end
