# frozen_string_literal: true

module Owner
  class ApplicationPolicy
    attr_reader :user, :record

    def initialize(user, record)
      @user = user
      @record = record
    end

    def index?
      owner?
    end

    def show?
      owner?
    end

    private

    def owner?
      user.has_role?(:owner)
    end
  end
end
