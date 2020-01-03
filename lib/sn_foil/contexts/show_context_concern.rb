# frozen_string_literal: true

require 'active_support/concern'
require_relative './setup_context_concern'

module SnFoil
  module Contexts
    module ShowContextConcern
      extend ActiveSupport::Concern

      included do
        include SetupContextConcern
      end

      class_methods do
        def show(id:, user: nil, **options)
          new(user).show(**options, id: id)
        end
      end

      def setup_show_object(id: nil, object: nil, **_options)
        raise ArgumentError, 'one of the following keywords is required: id, object' unless id || object

        wrap_object(object || scope.resolve.find(id))
      end

      def show(**options)
        options[:action] = :show
        object = setup_show_object(**options)
        authorize(object, :show?, **options)
        object
      end
    end
  end
end
