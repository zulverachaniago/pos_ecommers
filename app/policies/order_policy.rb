class OrderPolicy < ApplicationPolicy
  def index?
    staff?
  end

  def show?
    staff?
  end

  def update?
    staff?
  end

  def shipping_slip?
    staff?
  end

  private

  def staff?
    user.has_role?(:admin) || user.has_role?(:cashier)
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
