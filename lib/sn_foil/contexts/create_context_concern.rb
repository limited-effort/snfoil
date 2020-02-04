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
        object = if object
                   wrap_object(object)
                 else
                   klass = options.fetch(:model) { model }
                   wrap_object(klass).new
                 end

        object.attributes = params
        options.merge! object: object
      end

      def create(**options)
        options[:action] = :create
        options = setup_change(setup_create(**options))
        options = setup_create_object(**options)
        authorize(options[:object], :create?, **options)
        options = create_hooks(**options)
        unwrap_object(options[:object])
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
      def create_hooks(options)
        options = before_create_save(**options)
        options = if options[:object].save
                    after_create_save_success(**options)
                  else
                    after_create_save_failure(**options)
                  end
        after_create_save(**options)
      end

      def before_create_save(**options)
        options = before_create(**options)
        options = before_create_hooks.reduce(options) { |opts, hook| run_hook(hook, opts) }
        options = before_change(**options)
        before_change_hooks.reduce(options) { |opts, hook| run_hook(hook, opts) }
      end

      def after_create_save(**options)
        options = after_create(**options)
        options = after_create_hooks.reduce(options) { |opts, hook| run_hook(hook, opts) }
        options = after_change(**options)
        after_change_hooks.reduce(options) { |opts, hook| run_hook(hook, opts) }
      end

      def after_create_save_success(**options)
        options = after_create_success(**options)
        options = after_create_success_hooks.reduce(options) { |opts, hook| run_hook(hook, opts) }
        options = after_change_success(**options)
        after_change_success_hooks.reduce(options) { |opts, hook| run_hook(hook, opts) }
      end

      def after_create_save_failure(**options)
        options = after_create_failure(**options)
        options = after_create_failure_hooks.reduce(options) { |opts, hook| run_hook(hook, opts) }
        options = after_change_failure(**options)
        after_change_failure_hooks.reduce(options) { |opts, hook| run_hook(hook, opts) }
      end
    end
  end
end
