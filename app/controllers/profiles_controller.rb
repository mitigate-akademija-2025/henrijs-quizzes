class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show]

  def index
    authorize User
    @users = policy_scope(User).order(created_at: :desc).page(params[:page]).per(20)
  end

  def me
    redirect_to profile_path(current_user)
  end

  def show
    authorize @user
    @games = Game.where(user_id: @user.id)
                 .where.not(finished_at: nil)
                 .includes(quiz: :user)
                 .order(finished_at: :desc, id: :desc)
                 .page(params[:page]).per(10)
  end

  private
  def set_user
    @user = User.find(params[:id])
  end
end
