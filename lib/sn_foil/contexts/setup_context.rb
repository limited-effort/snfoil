# frozen_string_literal: true

require 'active_support/concern'
require 'active_support/core_ext/string/inflections'

module SnFoil
  module Contexts
    module SetupContext
      extend ActiveSupport::Concern

      class_methods do
        attr_reader :i_model, :i_policy, :i_setup_hooks

        def model(klass = nil)
          @i_model = klass
        end

        def policy(klass = nil)
          @i_policy = klass
        end

        def setup(method = nil, **options, &block)
          raise ArgumentError, '#setup requires either a method name or a block' if method.nil? && block.nil?

          (@i_setup_hooks ||= []) << { method: method, block: block, if: options[:if], unless: options[:unless] }
        end
      end

      def model
        self.class.i_model
      end

      def policy
        self.class.i_policy
      end

      def setup(**options)
        options
      end

      def setup_hooks
        self.class.i_setup_hooks || []
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

      def run_hook(hook, **options)
        return options unless hook_valid?(hook, **options)

        return send(hook[:method], **options) if hook[:method]

        instance_exec options, &hook[:block]
      end

      def hook_valid?(hook, **options)
        return false if !hook[:if].nil? && hook[:if].call(options) == false
        return false if !hook[:unless].nil? && hook[:unless].call(options) == true

        true
      end

      private

      def lookup_policy(object, options)
        lookup = if options[:policy]
                   options[:policy].new(user, object)
                 elsif policy
                   policy.new(user, object)
                 else
                   Pundit.policy!(user, object)
                 end

        lookup.options = options if lookup.respond_to? :options=
        lookup
      end
    end
  end
end
