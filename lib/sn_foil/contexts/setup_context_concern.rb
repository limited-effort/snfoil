# frozen_string_literal: true

require 'active_support/concern'
require 'active_support/core_ext/string/inflections'

module SnFoil
  module Contexts
    module SetupContextConcern
      extend ActiveSupport::Concern

      class_methods do
        attr_reader :i_model_class, :i_policy_class

        def model_class(klass = nil)
          @i_model_class = klass
        end

        def policy_class(klass = nil)
          @i_policy_class = klass
        end
      end

      def model_class
        self.class.i_model_class
      end

      def policy_class
        self.class.i_policy_class
      end

      attr_reader :user
      def initialize(user = nil)
        @user = user
      end

      def authorize(object, action, **options)
        return unless user # Add logging

        policy(object, options).send(action)
      end

      def scope(object_class = nil, **options)
        object_class ||= model_class
        policy_name = policy(object_class, options).class.name
        "#{policy_name}::Scope".safe_constantize.new(wrap_object(object_class), user)
      end

      def wrap_object(object)
        return object unless adapter

        adapter.new(object)
      end

      def unwrap_object(object)
        return object unless adapter

        adapter?(object) ? object.__getobj__ : object
      end

      def adapter?(object)
        return false unless adapter

        object.instance_of? adapter
      end

      def adapter
        @adapter ||= SnFoil.adapter
      end

      private

      def policy(object, options)
        return options[:policy].new(user, object) if options[:policy]
        return policy_class.new(user, object) if policy_class

        Pundit.policy!(user, object)
      end
    end
  end
end
