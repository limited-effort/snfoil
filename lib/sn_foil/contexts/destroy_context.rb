# frozen_string_literal: true

require 'active_support/concern'
require_relative './setup_context'
require_relative './change_context'

module SnFoil
  module Contexts
    module DestroyContext
      extend ActiveSupport::Concern

      included do
        include SetupContext
        include ChangeContext
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

      def setup_destroy_object(id: nil, object: nil, **options)
        raise ArgumentError, 'one of the following keywords is required: id, object' unless id || object

        options.merge! object: wrap_object(object || scope.resolve.find(id))
      end

      def destroy(**options)
        options[:action] = :destroy
        options = setup_destroy(setup_change(**options))
        options = setup_destroy_object(**options)
        authorize(options[:object], :destroy?, **options)
        options = destroy_hooks(**options)
        unwrap_object(options[:object])
      end

      def setup_destroy(**options)
        options
      end

      def before_destroy(**options)
        options
      end

      def after_destroy(**options)
        options
      end

      def after_destroy_success(**options)
        options
      end

      def after_destroy_failure(**options)
        options
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
      def destroy_hooks(options)
        options = before_destroy_save(options)
        options = if options[:object].destroy
                    after_destroy_save_success(options)
                  else
                    after_destroy_save_failure(options)
                  end
        after_destroy_save(options)
      end

      def before_destroy_save(options)
        options = before_destroy(**options)
        options = before_destroy_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
        options = before_change(**options)
        before_change_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
      end

      def after_destroy_save(options)
        options = after_destroy(**options)
        options = after_destroy_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
        options = after_change(**options)
        after_change_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
      end

      def after_destroy_save_success(options)
        options = after_destroy_success(**options)
        options = after_destroy_success_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
        options = after_change_success(**options)
        after_change_success_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
      end

      def after_destroy_save_failure(options)
        options = after_destroy_failure(**options)
        options = after_destroy_failure_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
        options = after_change_failure(**options)
        after_change_failure_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
      end
    end
  end
end
