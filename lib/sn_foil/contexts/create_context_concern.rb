# frozen_string_literal: true

require 'active_support/concern'
require_relative './setup_context_concern'
require_relative './change_context_concern'

module SnFoil
  module Contexts
    module CreateContextConcern # rubocop:disable Metrics/ModuleLength
      extend ActiveSupport::Concern

      included do
        include SetupContextConcern
        include ChangeContextConcern
      end

      class_methods do
        attr_reader :i_before_create_hooks, :i_after_create_hooks, :i_after_create_success_hooks, :i_after_create_failure_hooks
        def create(params:, user: nil, **options)
          new(user).create(**options, params: params)
        end

        def before_create(method = nil, **options, &block)
          raise ArgumentError, '#on_create requires either a method name or a block' if method.nil? && block.nil?

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

      def setup_create_object(params: {}, object: nil, **options)
        return wrap_object(object) if object

        klass = options.fetch(:model_class) { model_class }
        object = wrap_object(klass).new
        object.attributes = params
        object
      end

      def create(**options)
        options[:action] = :create
        options = setup_change(setup_create(**options))
        object = setup_create_object(**options)
        authorize(object, :create?, **options)
        object = create_hooks(object, **options)
        unwrap_object(object)
      end

      def setup_create(**options)
        options
      end

      def before_create(object, **_options)
        object
      end

      def after_create(object, **_options)
        object
      end

      def after_create_success(object, **_options)
        object
      end

      def after_create_failure(object, **_options)
        object
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

      # This method is private to help protect the order of execution of hooks
      def create_hooks(object, options)
        object = before_create_save(object, **options)
        object = if object.save
                   after_create_save_success(object, **options)
                 else
                   after_create_save_failure(object, **options)
                 end
        after_create_save(object, **options)
      end

      def before_create_save(object, **options)
        object = before_create(object, **options)
        object = before_create_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
        object = before_change(object, **options)
        before_change_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
      end

      def after_create_save(object, **options)
        object = after_create(object, **options)
        object = after_create_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
        object = after_change(object, **options)
        after_change_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
      end

      def after_create_save_success(object, **options)
        object = after_create_success(object, **options)
        object = after_create_success_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
        object = after_change_success(object, **options)
        after_change_success_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
      end

      def after_create_save_failure(object, **options)
        object = after_create_failure(object, **options)
        object = after_create_failure_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
        object = after_change_failure(object, **options)
        after_change_failure_hooks.reduce(object) { |obj, hook| run_hook(hook, obj, **options) }
      end
    end
  end
end
