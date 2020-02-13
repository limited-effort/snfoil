# frozen_string_literal: true

require 'active_support/concern'

module SnFoil
  module Policy
    extend ActiveSupport::Concern

    attr_reader :record, :entity, :options
    def initialize(record, entity = nil, options = {})
      @record = record
      @entity = entity
      @options = options
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

    def associate?
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
