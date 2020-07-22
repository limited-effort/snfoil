# frozen_string_literal: true

require 'active_support/concern'
require_relative './setup_context'
require_relative './change_context'

module SnFoil
  module Contexts
    module DestroyContext # rubocop:disable Metrics/ModuleLength
      extend ActiveSupport::Concern

      included do
        include SetupContext
        include ChangeContext
      end

      class_methods do
        attr_reader :i_setup_destroy_hooks, :i_before_destroy_hooks, :i_after_destroy_hooks,
                    :i_after_destroy_success_hooks, :i_after_destroy_failure_hooks
        def destroy(id:, entity: nil, **options)
          new(entity).destroy(**options, id: id)
        end

        def setup_destroy(method = nil, **options, &block)
          raise ArgumentError, '#setup_destroy requires either a method name or a block' if method.nil? && block.nil?

          (@i_setup_destroy_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
        end

        def before_destroy(method = nil, **options, &block)
          raise ArgumentError, '#before_destroy requires either a method name or a block' if method.nil? && block.nil?

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
        options = before_setup_destroy_object(**options)
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

      def setup_destroy_hooks
        self.class.i_setup_destroy_hooks || []
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

      def before_setup_destroy_object(**options)
        options = setup_destroy(**options)
        options = setup_destroy_hooks.reduce(options) { |opts, hook| run_hook(hook, opts) }
        options = setup_change(**options)
        options = setup_change_hooks.reduce(options) { |opts, hook| run_hook(hook, opts) }
        options = setup(**options)
        setup_hooks.reduce(options) { |opts, hook| run_hook(hook, opts) }
      end

      # This method is private to help protect the order of execution of hooks
      def destroy_hooks(options)
        options = before_destroy_save(options)
        destroy_successful = options[:object].destroy
        options.merge!(object: unwrap_object(options[:object]))
        options = if destroy_successful
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
