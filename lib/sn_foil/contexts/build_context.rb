# frozen_string_literal: true

require 'active_support/concern'
require_relative './setup_context'
require_relative './change_context'

module SnFoil
  module Contexts
    module BuildContext
      extend ActiveSupport::Concern

      included do
        include SetupContext
        include ChangeContext
      end

      class_methods do
        def build(params:, entity: nil, **options)
          new(entity).build(**options, params: params)
        end
      end

      def setup_build_object(params: {}, object: nil, **options)
        SnFoil.logger.info 'Warning: Using build bypasses authorize.  It is safer to interact with models through create' unless ENV['ISTEST']
        return wrap_object(object) if object

        klass = options.fetch(:model) { model }
        options.merge! object: wrap_object(klass).new(**params)
      end

      def build(**options)
        options[:action] = :build
        options = setup_build(setup_change(**options))
        options = setup_build_object(**options)
        unwrap_object(options[:object])
      end

      def setup_build(**options)
        options
      end
    end
  end
end
