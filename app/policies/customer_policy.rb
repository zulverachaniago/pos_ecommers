class CustomerPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  def index?
    user.has_role?(:admin) || user.has_role?(:cashier)
  end

  def show?
    user.has_role?(:admin) || user.has_role?(:cashier)
  end

  def new?
    user.has_role?(:admin) || user.has_role?(:cashier)
  end
  
  def create?
    user.has_role?(:admin) || user.has_role?(:cashier)
  end
  
  def edit?
    user.has_role?(:admin) || user.has_role?(:cashier)
  end
  
  def update?
    user.has_role?(:admin) || user.has_role?(:cashier)
  end
  
  def destroy?
    user.has_role?(:admin) || user.has_role?(:cashier)
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
