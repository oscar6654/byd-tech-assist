class Tarfs::CommentsController < ApplicationController
  before_action :set_tarf

  def create
    @comment = @tarf.tarf_comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @tarf, notice: "Comment added." }
      end
    else
      redirect_to @tarf, alert: "Could not add comment."
    end
  end

  def destroy
    @comment = @tarf.tarf_comments.find(params[:id])
    if @comment.user == current_user || current_user.admin?
      @comment.destroy
      redirect_to @tarf, notice: "Comment deleted."
    else
      redirect_to @tarf, alert: "You can only delete your own comments."
    end
  end

  private

  def set_tarf
    @tarf = Tarf.find(params[:tarf_id])
  end

  def comment_params
    params.require(:tarf_comment).permit(:body, attachments: [])
  end
end
