# frozen_string_literal: true

require 'active_support/concern'
require_relative './setup_context_concern'

module SnFoil
  module Contexts
    module ChangeContextConcern
      extend ActiveSupport::Concern

      included do
        include SetupContextConcern
      end

      class_methods do
        attr_reader :i_params

        def params(*whitelisted_params)
          @i_params ||= []
          @i_params |= whitelisted_params
        end
      end

      def param_names
        @param_names ||= self.class.i_params
      end

      def setup_change(**options)
        options[:params] = options[:params].select { |params| param_names.include?(params) } if param_names
        options
      end

      def before_change(object, **_options)
        object
      end

      def after_change_success(object, **_options)
        object
      end

      def after_change_failure(object, **_options)
        object
      end
    end
  end
end
