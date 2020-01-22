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
        attr_reader :i_before_destroy_hooks, :i_after_destroy_hooks, :i_after_destroy_success_hooks, :i_after_destroy_failure_hooks
        def destroy(id:, user: nil, **options)
          new(user).destroy(**options, id: id)
        end

        def before_destroy(method = nil, **options, &block)
          raise ArgumentError, '#on_destroy requires either a method name or a block' if method.nil? && block.nil?

          (@i_before_destroy_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
        end

        def after_destroy(method = nil, **options, &block)
          raise ArgumentError, '#after_destroy requires either a method name or a block' if method.nil? && block.nil?

          (@i_after_destroy_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
        end

        def after_destroy_success(method = nil, **options, &block)
          raise ArgumentError, '#after_destroy_success requires either a method name or a block' if method.nil? && block.nil?

          (@i_after_destroy_success_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
        end

        def after_destroy_failure(method = nil, **options, &block)
          raise ArgumentError, '#after_destroy_failure requires either a method name or a block' if method.nil? && block.nil?

          (@i_after_destroy_failure_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
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

      def after_destroy(object, **_options)
        object
      end

      def after_destroy_success(object, **_options)
        object
      end

      def after_destroy_failure(object, **_options)
        object
      end

      def before_destroy_hooks
        self.class.i_before_destroy_hooks || []
      end

      def after_destroy_hooks
        self.class.i_after_destroy_hooks || []
      end

      def after_destroy_success_hooks
        self.class.i_after_destroy_success_hooks || []
      end

      def after_destroy_failure_hooks
        self.class.i_after_destroy_failure_hooks || []
      end

      private

      # This method is private to help protect the order of execution of hooks
      def destroy_hooks(object, options)
        object = before_destroy_save(object, **options)
        object = if object.destroy
                   after_destroy_save_success(object, **options)
                 else
                   after_destroy_save_failure(object, **options)
                 end
        after_destroy_save(object, **options)
      end

      def before_destroy_save(object, **options)
        object = before_destroy(object, **options)
        object = before_destroy_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
        object = before_change(object, **options)
        before_change_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
      end

      def after_destroy_save(object, **options)
        object = after_destroy(object, **options)
        object = after_destroy_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
        object = after_change(object, **options)
        after_change_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
      end

      def after_destroy_save_success(object, **options)
        object = after_destroy_success(object, **options)
        object = after_destroy_success_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
        object = after_change_success(object, **options)
        after_change_success_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
      end

      def after_destroy_save_failure(object, **options)
        object = after_destroy_failure(object, **options)
        object = after_destroy_failure_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
        object = after_change_failure(object, **options)
        after_change_failure_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
      end
    end
  end
end
