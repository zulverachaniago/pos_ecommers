# frozen_string_literal: true

class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user.has_role?(:admin) || user.has_role?(:cashier)
  end

  def show?
    user.has_role?(:admin) || user.has_role?(:cashier)
  end

  def create?
    user.has_role?(:admin)
  end

  def update?
    user.has_role?(:admin)
  end

  def destroy?
    user.has_role?(:admin)
  end


  class Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end


end
