# frozen_string_literal: true

require 'active_support/concern'
require 'active_support/core_ext/string/inflections'

module SnFoil
  module Contexts
    module SetupContextConcern
      extend ActiveSupport::Concern

      class_methods do
        attr_reader :i_model, :i_policy

        def model(klass = nil)
          @i_model = klass
        end

        def policy(klass = nil)
          @i_policy = klass
        end
      end

      def model
        self.class.i_model
      end

      def policy
        self.class.i_policy
      end

      attr_reader :user
      def initialize(user = nil)
        @user = user
      end

      def authorize(object, action, **options)
        return unless user # Add logging

        policy = lookup_policy(object, options)
        raise Pundit::NotAuthorizedError, query: action, record: object, policy: policy unless policy.public_send(action)
        true
      end

      def scope(object_class = nil, **options)
        object_class ||= model
        policy_name = lookup_policy(object_class, options).class.name
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

      def lookup_policy(object, options)
        return options[:policy].new(user, object) if options[:policy]
        return policy.new(user, object) if policy

        Pundit.policy!(user, object)
      end
    end
  end
end
