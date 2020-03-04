# frozen_string_literal: true

require 'active_support/concern'
require_relative './setup_context'

module SnFoil
  module Contexts
    module ChangeContext
      extend ActiveSupport::Concern

      included do
        include SetupContext
      end

      class_methods do # rubocop:disable Metrics/BlockLength
        attr_reader :i_params, :i_setup_change_hooks, :i_before_change_hooks, :i_after_change_hooks,
                    :i_after_change_success_hooks, :i_after_change_failure_hooks
        def params(*whitelisted_params)
          @i_params ||= []
          @i_params |= whitelisted_params
        end

        def setup_change(method = nil, **options, &block)
          raise ArgumentError, '#setup_change requires either a method name or a block' if method.nil? && block.nil?

          (@i_setup_change_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
        end

        def before_change(method = nil, **options, &block)
          raise ArgumentError, '#before_change requires either a method name or a block' if method.nil? && block.nil?

          (@i_before_change_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
        end

        def after_change(method = nil, **options, &block)
          raise ArgumentError, '#after_change requires either a method name or a block' if method.nil? && block.nil?

          (@i_after_change_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
        end

        def after_change_success(method = nil, **options, &block)
          raise ArgumentError, '#after_change_success requires either a method name or a block' if method.nil? && block.nil?

          (@i_after_change_success_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
        end

        def after_change_failure(method = nil, **options, &block)
          raise ArgumentError, '#after_change_failure requires either a method name or a block' if method.nil? && block.nil?

          (@i_after_change_failure_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
        end
      end

      def param_names
        @param_names ||= self.class.i_params
      end

      def setup_change(**options)
        options[:params] = options[:params].select { |params| param_names.include?(params) } if param_names
        options
      end

      def before_change(**options)
        options
      end

      def after_change(**options)
        options
      end

      def after_change_success(**options)
        options
      end

      def after_change_failure(**options)
        options
      end

      def setup_change_hooks
        self.class.i_setup_change_hooks || []
      end

      def before_change_hooks
        self.class.i_before_change_hooks || []
      end

      def after_change_hooks
        self.class.i_after_change_hooks || []
      end

      def after_change_success_hooks
        self.class.i_after_change_success_hooks || []
      end

      def after_change_failure_hooks
        self.class.i_after_change_failure_hooks || []
      end
    end
  end
end
