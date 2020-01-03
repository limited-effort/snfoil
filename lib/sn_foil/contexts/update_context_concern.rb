# frozen_string_literal: true

require 'active_support/concern'
require_relative './setup_context_concern'
require_relative './change_context_concern'

module SnFoil
  module Contexts
    module UpdateContextConcern
      extend ActiveSupport::Concern

      included do
        include SetupContextConcern
        include ChangeContextConcern
      end

      class_methods do
        def update(id:, params:, user: nil, **options)
          new(user).update(**options, id: id, params: params)
        end
      end

      def setup_update_object(params: {}, id: nil, object: nil, **options)
        raise ArgumentError, 'one of the following keywords is required: id, object' unless id || object

        object = wrap_object(object || scope.resolve.find(id))
        authorize(object, :update?, **options)
        object.attributes = params
        object
      end

      def update(**options)
        options[:action] = :update
        options = setup_change(setup_update(**options))
        object = setup_update_object(**options)
        authorize(object, :update?, **options)
        object = update_hooks(object, **options)
        unwrap_object(object)
      end

      def setup_update(**options)
        options
      end

      def before_update(object, **_options)
        object
      end

      def after_update_success(object, **_options)
        object
      end

      def after_update_failure(object, **_options)
        object
      end

      private

      # This method is private to help protect the order of execution of hooks
      def update_hooks(object, **options)
        object = before_update(object, **options)
        object = before_change(object, **options)
        if object.save
          object = after_update_success(object, **options)
          object = after_change_success(object, **options)
        else
          object = after_update_failure(object, **options)
          object = after_change_failure(object, **options)
        end
        object
      end
    end
  end
end
