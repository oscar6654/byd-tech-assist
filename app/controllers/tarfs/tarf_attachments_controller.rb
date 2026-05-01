class Tarfs::TarfAttachmentsController < ApplicationController
  before_action :set_tarf

  def create
    raw_files = params.dig(:tarf_attachment, :files)
    files = Array(raw_files).reject { |f| f.blank? }
    folder_id = params.dig(:tarf_attachment, :tarf_folder_id).presence
    saved = 0

    files.each do |file|
      attachment = @tarf.tarf_attachments.build(tarf_folder_id: folder_id)
      attachment.user = current_user
      attachment.file.attach(file)
      saved += 1 if attachment.save
    end

    if saved > 0
      redirect_to @tarf, notice: "#{saved} #{'file'.pluralize(saved)} uploaded."
    else
      redirect_to @tarf, alert: "No files were uploaded. Please select files first."
    end
  end

  def destroy
    @attachment = @tarf.tarf_attachments.find(params[:id])
    unless @attachment.can_delete?(current_user)
      redirect_to @tarf, alert: "Only the TARF creator or admin can delete files."
      return
    end

    @attachment.file.purge_later
    @attachment.destroy
    redirect_to @tarf, notice: "File deleted."
  end

  private

  def set_tarf
    @tarf = Tarf.find(params[:tarf_id])
  end
end
