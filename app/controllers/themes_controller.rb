class ThemesController < ApplicationController
  def update
    current_user.update(theme: params[:theme])
    head :ok
  end
end
