# frozen_string_literal: true

require 'active_support/concern'
require_relative './setup_context'

module SnFoil
  module Contexts
    module BuildContext
      extend ActiveSupport::Concern

      included do
        include SetupContext
      end

      class_methods do
        attr_reader :i_setup_build_hooks

        def build(params:, entity: nil, **options)
          new(entity).build(**options, params: params)
        end

        def setup_build(method = nil, **options, &block)
          raise ArgumentError, '#setup_build requires either a method name or a block' if method.nil? && block.nil?

          (@i_setup_build_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
        end
      end

      def setup_build_object(params: {}, object: nil, **options)
        object = if object
                   wrap_object(object)
                 else
                   klass = options.fetch(:model) { model }
                   wrap_object(klass).new
                 end

        object.attributes = params
        options.merge! object: object
      end

      def build(**options)
        options[:action] = :build
        options = before_setup_build_object(**options)
        options = setup_build_object(**options)
        authorize(options[:object], options[:authorize], **options) if options[:authorize]
        unwrap_object(options[:object])
      end

      def setup_build(**options)
        options
      end

      def setup_build_hooks
        self.class.i_setup_build_hooks || []
      end

      private

      def before_setup_build_object(**options)
        options = setup(**options)
        options = setup_hooks.reduce(options) { |opts, hook| run_hook(hook, opts) }
        options = setup_build(**options)
        setup_build_hooks.reduce(options) { |opts, hook| run_hook(hook, opts) }
      end
    end
  end
end
