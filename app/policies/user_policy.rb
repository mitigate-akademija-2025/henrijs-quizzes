class UserPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin? || owner?
  end

  def update?
    admin? || owner?
  end

 class Scope < Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.none
      end
    end
 end

  private

  def admin?
    user&.admin?
  end

  def owner?
    user.present? && record.is_a?(User) && user.id == record.id
  end
end
