# frozen_string_literal: true

require 'active_support/concern'
require 'active_support/core_ext/module/attribute_accessors'

module SnFoil
  module Searcher
    extend ActiveSupport::Concern

    class_methods do
      attr_reader :i_model_class, :i_setup, :i_filters

      def model_class(klass = nil)
        @i_model_class = klass
      end

      def setup(&setup_block)
        @i_setup = setup_block
      end

      def filter(method = nil, **options, &block)
        raise ArgumentError, 'filter requires either a method name or a block' if method.nil? && block.nil?

        (@i_filters ||= []) << {
          method: method,
          block: block,
          if: options[:if],
          unless: options[:unless]
        }
      end
    end

    def model_class
      self.class.i_model_class
    end

    attr_reader :initial_scope, :scope, :params, :options
    def initialize(scope: nil, params: {}, **options)
      @initial_scope = @scope = scope || model_class.all
      @params = params
      @options = options
    end

    def reset_scope
      @scope = initial_scope
    end

    def filtered_results
      scope
    end

    def results
      return scope if scope != initial_scope

      @scope = filtered_results
      @scope = apply_setup
      @scope = apply_filters
      scope
    end

    private

    def apply_setup
      return scope if self.class.i_setup.nil?

      self.class.i_setup.call(scope, params)
    end

    def apply_filters
      return scope if self.class.i_filters.nil?

      self.class.i_filters&.each do |filter|
        apply_filter(filter)
      end
      scope
    end

    def apply_filter(filter)
      return unless filter_valid?(filter)

      @scope = if filter[:method]
                 send(filter[:method], scope)
               else
                 filter[:block].call(scope, params)
               end
    end

    def filter_valid?(filter)
      return false if !filter[:if].nil? && filter[:if].call(params) == false
      return false if !filter[:unless].nil? && filter[:unless].call(params) == true

      true
    end
  end
end
