class ProfilesController < ApplicationController
  before_action :authenticate_user!

  def show; end

  def completed_games
    @games = Game
      .where(user_id: current_user.id)
      .where.not(finished_at: nil)
      .includes(quiz: :user)
      .order(finished_at: :desc, id: :desc)
      .page(params[:page]).per(10)
  end
end
