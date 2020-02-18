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
        def show(id:, user: nil, **options)
          new(user).show(**options, id: id)
        end
      end

      def setup_show_object(id: nil, object: nil, **options)
        raise ArgumentError, 'one of the following keywords is required: id, object' unless id || object

        options.merge! object: wrap_object(object || scope.resolve.find(id))
      end

      def show(**options)
        options[:action] = :show
        options = setup_show_object(**options)
        authorize(options[:object], :show?, **options)
        unwrap_object options[:object]
      end
    end
  end
end
