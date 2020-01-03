# frozen_string_literal: true

require 'active_support/concern'
require_relative './setup_context_concern'
require_relative './change_context_concern'

module SnFoil
  module Contexts
    module BuildContextConcern
      extend ActiveSupport::Concern

      included do
        include SetupContextConcern
        include ChangeContextConcern
      end

      class_methods do
        def build(params:, user: nil, **options)
          new(user).build(**options, params: params)
        end
      end

      def setup_build_object(params: {}, object: nil, **options)
        SnFoil.logger.info 'Warning: Using build bypasses authorize.  It is safer to interact with models through create' unless ENV['ISTEST']
        return wrap_object(object) if object

        klass = options.fetch(:model_class) { model_class }
        wrap_object(klass).new(**params)
      end

      def build(**options)
        options[:action] = :build
        options = setup_build(setup_change(**options))
        object = setup_build_object(**options)
        unwrap_object(object)
      end

      def setup_build(**options)
        options
      end
    end
  end
end
