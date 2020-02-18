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
        attr_reader :i_searcher

        def index(params: {}, user: nil, **options)
          new(user).index(**options, params: params)
        end

        def searcher(klass = nil)
          @i_searcher = klass
        end
      end

      def searcher
        self.class.i_searcher
      end

      def index(params:, **options)
        options[:action] = :index
        options = setup_index(**options)
        options.fetch(:searcher) { searcher }
               .new(scope: scope.resolve)
               .search(params: params)
      end

      # Param manipulation based on User should be done here
      def setup_index(**options)
        options
      end
    end
  end
end
