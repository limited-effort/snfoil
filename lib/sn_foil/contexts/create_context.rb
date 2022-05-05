# frozen_string_literal: true

require 'active_support/concern'
require_relative './change_context'

module SnFoil
  module Contexts
    module CreateContext # rubocop:disable Metrics/ModuleLength
      extend ActiveSupport::Concern

      included do
        include BuildContext
        include ChangeContext

        alias_method :setup_create_object, :setup_build_object
      end

      class_methods do
        attr_reader :i_setup_create_hooks, :i_before_create_hooks, :i_after_create_hooks,
                    :i_after_create_success_hooks, :i_after_create_failure_hooks

        def create(params:, entity: nil, **options)
          new(entity).create(**options, params: params)
        end

        def setup_create(method = nil, **options, &block)
          raise ArgumentError, '#setup_create requires either a method name or a block' if method.nil? && block.nil?

          (@i_setup_create_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
        end

        def before_create(method = nil, **options, &block)
          raise ArgumentError, '#before_create requires either a method name or a block' if method.nil? && block.nil?

          (@i_before_create_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
        end

        def after_create(method = nil, **options, &block)
          raise ArgumentError, '#after_create requires either a method name or a block' if method.nil? && block.nil?

          (@i_after_create_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
        end

        def after_create_success(method = nil, **options, &block)
          raise ArgumentError, '#after_create_success requires either a method name or a block' if method.nil? && block.nil?

          (@i_after_create_success_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
        end

        def after_create_failure(method = nil, **options, &block)
          raise ArgumentError, '#after_create_failure requires either a method name or a block' if method.nil? && block.nil?

          (@i_after_create_failure_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
        end
      end

      def create(**options)
        options[:action] = :create
        options = before_setup_build_object(**options)
        options = before_setup_create_object(**options)
        options = setup_create_object(**options)
        authorize(options[:object], options.fetch(:authorize, :create?), **options)
        options = create_hooks(**options)
        options[:object]
      end

      def setup_create(**options)
        options
      end

      def before_create(**options)
        options
      end

      def after_create(**options)
        options
      end

      def after_create_success(**options)
        options
      end

      def after_create_failure(**options)
        options
      end

      def setup_create_hooks
        self.class.i_setup_create_hooks || []
      end

      def before_create_hooks
        self.class.i_before_create_hooks || []
      end

      def after_create_hooks
        self.class.i_after_create_hooks || []
      end

      def after_create_success_hooks
        self.class.i_after_create_success_hooks || []
      end

      def after_create_failure_hooks
        self.class.i_after_create_failure_hooks || []
      end

      private

      def before_setup_create_object(**options)
        options = setup_change(**options)
        options = setup_change_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
        options = setup_create(**options)
        setup_create_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
      end

      # This method is private to help protect the order of execution of hooks
      def create_hooks(options)
        options = before_create_save(**options)
        save_successful = options[:object].save
        options[:object] = unwrap_object(options[:object])
        options = if save_successful
                    after_create_save_success(**options)
                  else
                    after_create_save_failure(**options)
                  end
        after_create_save(**options)
      end

      def before_create_save(**options)
        options = before_change(**options)
        options = before_change_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
        options = before_create(**options)
        before_create_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
      end

      def after_create_save(**options)
        options = after_change(**options)
        options = after_change_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
        options = after_create(**options)
        after_create_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
      end

      def after_create_save_success(**options)
        options = after_change_success(**options)
        options = after_change_success_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
        options = after_create_success(**options)
        after_create_success_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
      end

      def after_create_save_failure(**options)
        options = after_change_failure(**options)
        options = after_change_failure_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
        options = after_create_failure(**options)
        after_create_failure_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
      end
    end
  end
end
