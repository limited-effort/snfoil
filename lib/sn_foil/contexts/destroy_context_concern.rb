# frozen_string_literal: true

require 'active_support/concern'
require_relative './setup_context_concern'
require_relative './change_context_concern'

module SnFoil
  module Contexts
    module DestroyContextConcern
      extend ActiveSupport::Concern

      included do
        include SetupContextConcern
        include ChangeContextConcern
      end

      class_methods do
        def destroy(id:, user: nil, **options)
          new(user).destroy(**options, id: id)
        end
      end

      def setup_destroy_object(id: nil, object: nil, **_options)
        raise ArgumentError, 'one of the following keywords is required: id, object' unless id || object

        wrap_object(object || scope.resolve.find(id))
      end

      def destroy(**options)
        options[:action] = :destroy
        options = setup_destroy(setup_change(**options))
        object = setup_destroy_object(**options)
        authorize(object, :destroy?, **options)
        object = destroy_hooks(object, **options)
        unwrap_object(object)
      end

      def setup_destroy(**options)
        options
      end

      def before_destroy(object, **_options)
        object
      end

      def after_destroy_success(object, **_options)
        object
      end

      def after_destroy_failure(object, **_options)
        object
      end

      private

      def destroy_hooks(object, **options)
        object = before_destroy(object, **options)
        object = before_change(object, **options)
        if object.destroy
          object = after_destroy_success(object, **options)
          object = after_change_success(object, **options)
        else
          object = after_destroy_failure(object, **options)
          object = after_change_failure(object, **options)
        end
        object
      end
    end
  end
end
