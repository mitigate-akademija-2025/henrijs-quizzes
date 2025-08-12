class ProfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [ :show ]

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

    @quizzes = @user.quizzes
                .includes(:games)
                .order(created_at: :desc)
                .page(params[:q_page]).per(10)
  end

  def toggle_admin
    target = User.find(params[:id])
    authorize target, :toggle_admin?

    make_admin = ActiveModel::Type::Boolean.new.cast(params[:admin])

    # prevent removing the last admin
    if !make_admin && target.admin? && User.where(admin: true).where.not(id: target.id).none?
      return redirect_to profiles_path, alert: "Cannot remove the last admin."
    end

    target.update!(admin: make_admin)
    redirect_to profiles_path, notice: "#{target.username || target.email} is now #{make_admin ? 'an admin' : 'a standard user'}."
  end

  def destroy
    target = User.find(params[:id])
    authorize target, :destroy?

    if target.admin? && User.where(admin: true).where.not(id: target.id).none?
      return redirect_to profiles_path, alert: "Cannot delete the last admin."
    end

    target.destroy!
    redirect_to profiles_path, notice: "User deleted."
  end

  private
  def set_user
    @user = User.find(params[:id])
  end
end
