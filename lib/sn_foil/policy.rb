# frozen_string_literal: true

require 'active_support/concern'

module SnFoil
  module Policy
    extend ActiveSupport::Concern

    attr_reader :record, :entity
    def initialize(record, entity = nil)
      @record = record
      @entity = entity
    end

    def index?
      false
    end

    def show?
      false
    end

    def create?
      false
    end

    def update?
      false
    end

    def destroy?
      false
    end

    class Scope
      attr_reader :scope, :entity

      def initialize(scope, entity = nil)
        @entity = entity
        @scope = scope
      end

      def resolve
        scope.all
      end
    end
  end
end
