# frozen_string_literal: true

require 'active_support/concern'
require_relative './setup_context_concern'
require_relative './change_context_concern'

module SnFoil
  module Contexts
    module CreateContextConcern
      extend ActiveSupport::Concern

      included do
        include SetupContextConcern
        include ChangeContextConcern
      end

      class_methods do
        def create(params:, user: nil, **options)
          new(user).create(**options, params: params)
        end
      end

      def setup_create_object(params: {}, object: nil, **options)
        return wrap_object(object) if object

        klass = options.fetch(:model_class) { model_class }
        object = wrap_object(klass).new
        object.attributes = params
        object
      end

      def create(**options)
        options[:action] = :create
        options = setup_change(setup_create(**options))
        object = setup_create_object(**options)
        authorize(object, :create?, **options)
        object = create_hooks(object, **options)
        unwrap_object(object)
      end

      def setup_create(**options)
        options
      end

      def before_create(object, **_options)
        object
      end

      def after_create_success(object, **_options)
        object
      end

      def after_create_failure(object, **_options)
        object
      end

      private

      # This method is private to help protect the order of execution of hooks
      def create_hooks(object, **options)
        object = before_create(object, **options)
        object = before_change(object, **options)
        if object.save
          object = after_create_success(object, **options)
          object = after_change_success(object, **options)
        else
          object = after_create_failure(object, **options)
          object = after_change_failure(object, **options)
        end
        object
      end
    end
  end
end
