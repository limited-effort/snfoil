# frozen_string_literal: true

require 'active_support/concern'
require_relative './setup_context'
require_relative './change_context'

module SnFoil
  module Contexts
    module UpdateContext # rubocop:disable Metrics/ModuleLength
      extend ActiveSupport::Concern

      included do
        include SetupContext
        include ChangeContext
      end

      class_methods do
        attr_reader :i_setup_update_hooks, :i_before_update_hooks, :i_after_update_hooks,
                    :i_after_update_success_hooks, :i_after_update_failure_hooks
        def update(id:, params:, user: nil, **options)
          new(user).update(**options, id: id, params: params)
        end

        def setup_update(method = nil, **options, &block)
          raise ArgumentError, '#setup_update requires either a method name or a block' if method.nil? && block.nil?

          (@i_setup_update_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
        end

        def before_update(method = nil, **options, &block)
          raise ArgumentError, '#before_update requires either a method name or a block' if method.nil? && block.nil?

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
        options.merge! object: object
      end

      def update(**options)
        options[:action] = :update
        options = before_setup_update_object(**options)
        options = setup_update_object(**options)
        authorize(options[:object], :update?, **options)
        options = update_hooks(**options)
        unwrap_object(options[:object])
      end

      def setup_update(**options)
        options
      end

      def before_update(**options)
        options
      end

      def after_update(**options)
        options
      end

      def after_update_success(**options)
        options
      end

      def after_update_failure(**options)
        options
      end

      def setup_update_hooks
        self.class.i_setup_update_hooks || []
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

      def before_setup_update_object(**options)
        options = setup_update(**options)
        options = setup_update_hooks.reduce(options) { |opts, hook| run_hook(hook, opts) }
        options = setup_change(**options)
        options = setup_change_hooks.reduce(options) { |opts, hook| run_hook(hook, opts) }
        options = setup(**options)
        setup_hooks.reduce(options) { |opts, hook| run_hook(hook, opts) }
      end

      # This method is private to help protect the order of execution of hooks
      def update_hooks(options)
        options = before_update_save(options)
        options = if options[:object].save
                    after_update_save_success(options)
                  else
                    after_update_save_failure(options)
                  end
        after_update_save(options)
      end

      def before_update_save(options)
        options = before_update(**options)
        options = before_update_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
        options = before_change(**options)
        before_change_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
      end

      def after_update_save(options)
        options = after_update(**options)
        options = after_update_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
        options = after_change(**options)
        after_change_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
      end

      def after_update_save_success(options)
        options = after_update_success(**options)
        options = after_update_success_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
        options = after_change_success(**options)
        after_change_success_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
      end

      def after_update_save_failure(options)
        options = after_update_failure(**options)
        options = after_update_failure_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
        options = after_change_failure(**options)
        after_change_failure_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
      end
    end
  end
end
