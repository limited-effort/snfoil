# frozen_string_literal: true

require 'active_support/concern'
require_relative './setup_context'

module SnFoil
  module Contexts
    module ShowContext
      extend ActiveSupport::Concern

      included do
        include SetupContext
      end

      class_methods do
        attr_reader :i_setup_show_hooks

        def show(id:, entity: nil, **options)
          new(entity).show(**options, id: id)
        end

        def setup_show(method = nil, **options, &block)
          raise ArgumentError, '#setup_show requires either a method name or a block' if method.nil? && block.nil?

          (@i_setup_show_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
        end
      end

      def setup_show_object(id: nil, object: nil, **options)
        raise ArgumentError, 'one of the following keywords is required: id, object' unless id || object

        options.merge! object: wrap_object(object || scope.resolve.find(id))
      end

      def setup_show_hooks
        self.class.i_setup_show_hooks || []
      end

      def show(**options)
        options[:action] = :show
        options = before_setup_show(**options)
        options = setup_show_object(**options)
        authorize(options[:object], :show?, **options)
        unwrap_object options[:object]
      end

      def setup_show(**options)
        options
      end

      private

      def before_setup_show(**options)
        options = setup_show(**options)
        options = setup_show_hooks.reduce(options) { |opts, hook| run_hook(hook, opts) }
        options = setup(**options)
        setup_hooks.reduce(options) { |opts, hook| run_hook(hook, opts) }
      end
    end
  end
end
