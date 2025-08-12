class GamePolicy < ApplicationPolicy
  def create?  = true
  def show?    = true

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end
