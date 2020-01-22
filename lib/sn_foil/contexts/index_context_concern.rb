# frozen_string_literal: true

require 'active_support/concern'
require_relative './change_context_concern'

module SnFoil
  module Contexts
    module IndexContextConcern
      extend ActiveSupport::Concern

      included do
        include SetupContextConcern
      end

      class_methods do
        attr_reader :i_searcher_class

        def index(params: {}, user: nil, **options)
          new(user).index(**options, params: params)
        end

        def searcher_class(klass = nil)
          @i_searcher_class = klass
        end
      end

      def searcher_class
        self.class.i_searcher_class
      end

      def index(params:, **options)
        options[:action] = :index
        options = setup_index(**options)
        options.fetch(:searcher) { searcher_class }
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
