# frozen_string_literal: true

require 'active_support/concern'
require 'active_support/core_ext/module/attribute_accessors'

module SnFoil
  module Searcher
    extend ActiveSupport::Concern

    included do
      TRUE = 'true'
      FALSE = 'false'
    end

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

    attr_reader :scope
    def initialize(scope: nil)
      @scope = scope || model_class.all
    end

    def search(params = {})
      params = transform_params_booleans(params) # this is required for params coming in from http-like sources
      filtered_scope = filter || scope # start usimg the default scope of the class or the filter method
      filtered_scope = apply_setup(filtered_scope, params)
      apply_filters(filtered_scope, params)
    end

    def filter; end

    def setup
      self.class.i_setup
    end

    def filters
      self.class.i_filters || []
    end

    private

    def apply_setup(filtered_scope, params)
      return filtered_scope if setup.nil?

      setup.call(filtered_scope, params)
    end

    def apply_filters(filtered_scope, params)
      filters&.reduce(filtered_scope) do |i_scope, i_filter|
        apply_filter(i_filter, i_scope, params)
      end
    end

    def apply_filter(i_filter, filtered_scope, params)
      return filtered_scope unless filter_valid?(i_filter, params)

      return send(i_filter[:method], filtered_scope, params) if i_filter[:method]

      i_filter[:block].call(filtered_scope, params)
    end

    def filter_valid?(i_filter, params)
      return false if !i_filter[:if].nil? && i_filter[:if].call(params) == false
      return false if !i_filter[:unless].nil? && i_filter[:unless].call(params) == true

      true
    end

    def transform_params_booleans(params)
      params.map do |key, value|
        value = if value == TRUE
                  true
                elsif value == FALSE
                  false
                else
                  value
                end
        [key, value]
      end.to_h
    end
  end
end
