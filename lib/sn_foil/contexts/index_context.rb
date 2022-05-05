# frozen_string_literal: true

require 'active_support/concern'
require_relative './change_context'

module SnFoil
  module Contexts
    module IndexContext
      extend ActiveSupport::Concern

      included do
        include SetupContext
      end

      class_methods do
        attr_reader :i_searcher, :i_setup_index_hooks

        def index(params: {}, entity: nil, **options)
          new(entity).index(**options, params: params)
        end

        def searcher(klass = nil)
          @i_searcher = klass
        end

        def setup_index(method = nil, **options, &block)
          raise ArgumentError, '#setup_index requires either a method name or a block' if method.nil? && block.nil?

          (@i_setup_index_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
        end
      end

      def searcher
        self.class.i_searcher
      end

      def setup_index_hooks
        self.class.i_setup_index_hooks || []
      end

      def index(**options)
        options[:action] = :index
        options = before_setup_index(**options)
        authorize(nil, :index?, **options)
        options.fetch(:searcher) { searcher }
               .new(scope: scope.resolve)
               .search(options.fetch(:params) { {} })
      end

      def setup_index(**options)
        options
      end

      private

      def before_setup_index(**options)
        options = setup(**options)
        options = setup_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
        options = setup_index(**options)
        setup_index_hooks.reduce(options) { |opts, hook| run_hook(hook, **opts) }
      end
    end
  end
end
