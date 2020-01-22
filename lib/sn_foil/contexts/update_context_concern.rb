# frozen_string_literal: true

require 'active_support/concern'
require_relative './setup_context_concern'
require_relative './change_context_concern'

module SnFoil
  module Contexts
    module UpdateContextConcern # rubocop:disable Metrics/ModuleLength
      extend ActiveSupport::Concern

      included do
        include SetupContextConcern
        include ChangeContextConcern
      end

      class_methods do
        attr_reader :i_before_update_hooks, :i_after_update_hooks, :i_after_update_success_hooks, :i_after_update_failure_hooks
        def update(id:, params:, user: nil, **options)
          new(user).update(**options, id: id, params: params)
        end

        def before_update(method = nil, **options, &block)
          raise ArgumentError, '#on_update requires either a method name or a block' if method.nil? && block.nil?

          (@i_before_update_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
        end

        def after_update(method = nil, **options, &block)
          raise ArgumentError, '#after_update requires either a method name or a block' if method.nil? && block.nil?

          (@i_after_update_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
        end

        def after_update_success(method = nil, **options, &block)
          raise ArgumentError, '#after_update_success requires either a method name or a block' if method.nil? && block.nil?

          (@i_after_update_success_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
        end

        def after_update_failure(method = nil, **options, &block)
          raise ArgumentError, '#after_update_failure requires either a method name or a block' if method.nil? && block.nil?

          (@i_after_update_failure_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
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

      def after_update(object, **_options)
        object
      end

      def after_update_success(object, **_options)
        object
      end

      def after_update_failure(object, **_options)
        object
      end

      def before_update_hooks
        self.class.i_before_update_hooks || []
      end

      def after_update_hooks
        self.class.i_after_update_hooks || []
      end

      def after_update_success_hooks
        self.class.i_after_update_success_hooks || []
      end

      def after_update_failure_hooks
        self.class.i_after_update_failure_hooks || []
      end

      private

      # This method is private to help protect the order of execution of hooks
      def update_hooks(object, options)
        object = before_update_save(object, **options)
        object = if object.save
                   after_update_save_success(object, **options)
                 else
                   after_update_save_failure(object, **options)
                 end
        after_update_save(object, **options)
      end

      def before_update_save(object, **options)
        object = before_update(object, **options)
        object = before_update_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
        object = before_change(object, **options)
        before_change_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
      end

      def after_update_save(object, **options)
        object = after_update(object, **options)
        object = after_update_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
        object = after_change(object, **options)
        after_change_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
      end

      def after_update_save_success(object, **options)
        object = after_update_success(object, **options)
        object = after_update_success_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
        object = after_change_success(object, **options)
        after_change_success_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
      end

      def after_update_save_failure(object, **options)
        object = after_update_failure(object, **options)
        object = after_update_failure_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
        object = after_change_failure(object, **options)
        after_change_failure_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
      end
    end
  end
end
