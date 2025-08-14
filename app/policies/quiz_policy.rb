class QuizPolicy < ApplicationPolicy
  def create?  = user.present?
  def update?  = admin? || owner?
  def destroy? = admin? || owner?
  def show?    = true

  def generate_with_gemini?
    create?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end

  private

  def owner?  = user.present? && record.user_id == user.id
  def admin?  = user&.admin?
end
