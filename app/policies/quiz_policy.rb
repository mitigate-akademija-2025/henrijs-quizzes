class QuizPolicy < ApplicationPolicy
  def create?  = user.present?
  def update?  = admin? || owner?
  def destroy? = admin? || owner?
  def show?    = true

  private

  def owner?
    user.present? && record.user_id == user.id
  end

  def admin?
    user&.admin?
  end
end
