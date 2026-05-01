class Tarfs::TarfFoldersController < ApplicationController
  before_action :set_tarf

  def create
    @folder = @tarf.tarf_folders.build(folder_params)

    respond_to do |format|
      if @folder.save
        format.turbo_stream
        format.html { redirect_to @tarf, notice: "Folder created." }
      else
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_folder_form", partial: "tarfs/tarf_folders/form", locals: { tarf: @tarf, folder: @folder }) }
        format.html { redirect_to @tarf, alert: @folder.errors.full_messages.join(", ") }
      end
    end
  end

  def destroy
    @folder = @tarf.tarf_folders.find(params[:id])
    unless @tarf.can_manage?(current_user)
      redirect_to @tarf, alert: "Not authorized."
      return
    end

    @folder.destroy
    redirect_to @tarf, notice: "Folder and its files deleted."
  end

  private

  def set_tarf
    @tarf = Tarf.find(params[:tarf_id])
  end

  def folder_params
    params.require(:tarf_folder).permit(:name)
  end
end
