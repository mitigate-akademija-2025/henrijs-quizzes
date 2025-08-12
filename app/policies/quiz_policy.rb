class QuizPolicy < ApplicationPolicy
  def create?  = user.present?
  def update?  = admin? || owner?
  def destroy? = admin? || owner?
  def show?    = true

  class Scope < Scope
    def resolve
      scope.all
    end
  end

  private

  def owner?  = user.present? && record.user_id == user.id
  def admin?  = user&.admin?
end
