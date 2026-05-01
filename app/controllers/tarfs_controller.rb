class TarfsController < ApplicationController
  before_action :set_tarf, only: [:show, :edit, :update, :destroy, :resolve, :reopen]
  before_action :authorize_manage!, only: [:edit, :update, :destroy]

  def index
    @tarfs = Tarf.includes(:user, :dealer, :byd_model).sorted

    if params[:search].present?
      @tarfs = @tarfs.search_by_keyword(params[:search])
    end

    @tarfs = @tarfs.by_status(params[:status]) if params[:status].present?
    @tarfs = @tarfs.by_category(params[:category]) if params[:category].present?
    @tarfs = @tarfs.by_dealer(params[:dealer_id]) if params[:dealer_id].present?
    @tarfs = @tarfs.by_byd_model(params[:byd_model_id]) if params[:byd_model_id].present?

    @pagy, @tarfs = pagy(@tarfs)
  end

  def show
    @tarf.increment_views! unless @tarf.owned_by?(current_user)
    @folders = @tarf.tarf_folders.sorted.includes(tarf_attachments: { file_attachment: :blob })
    @general_attachments = @tarf.tarf_attachments.where(tarf_folder: nil).includes(file_attachment: :blob)
    @comments_pagy, @comments = pagy(@tarf.tarf_comments.sorted.includes(:user), items: 10, page_param: :comments_page)
    @new_comment = TarfComment.new
    @new_folder = TarfFolder.new
  end

  def new
    @tarf = Tarf.new
  end

  def create
    @tarf = current_user.tarfs.build(tarf_params)
    @tarf.dealer = current_user.dealer unless current_user.admin?

    if @tarf.save
      redirect_to @tarf, notice: "TARF created successfully. You can now add files."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @tarf.update(tarf_params)
      redirect_to @tarf, notice: "TARF updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @tarf.destroy
    redirect_to tarfs_path, notice: "TARF deleted."
  end

  def resolve
    unless @tarf.can_manage?(current_user)
      redirect_to @tarf, alert: "Only the creator or admin can resolve this TARF."
      return
    end

    if params[:tarf][:part_number].blank? || params[:tarf][:part_name].blank?
      redirect_to @tarf, alert: "Part number and part name are required to resolve."
      return
    end

    @tarf.resolve!(
      user: current_user,
      part_number: params[:tarf][:part_number],
      part_name: params[:tarf][:part_name],
      fix_description: params[:tarf][:fix_description]
    )
    redirect_to @tarf, notice: "TARF marked as resolved."
  end

  def reopen
    unless @tarf.can_manage?(current_user)
      redirect_to @tarf, alert: "Only the creator or admin can reopen this TARF."
      return
    end

    @tarf.reopen!
    redirect_to @tarf, notice: "TARF reopened."
  end

  private

  def set_tarf
    @tarf = Tarf.find(params[:id])
  end

  def authorize_manage!
    unless @tarf.can_manage?(current_user)
      redirect_to @tarf, alert: "You are not authorized to modify this TARF."
    end
  end

  def tarf_params
    params.require(:tarf).permit(:title, :description, :problem_summary, :byd_model_id, :dealer_id, :category, :keywords)
  end
end
