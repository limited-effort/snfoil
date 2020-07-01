# frozen_string_literal: true

require_relative 'base_adapter'

module SnFoil
  module Adapters
    module ORMs
      class ActiveRecord < SnFoil::Adapters::ORMs::BaseAdapter
        def new(**params)
          self.class.new(__getobj__.new(params))
        end

        def all
          __getobj__.all
        end

        def save
          __getobj__.save
        end

        def destroy
          __getobj__.destroy
          __getobj__.destroyed?
        end

        def attributes=(attributes)
          __getobj__.attributes = attributes
        end
      end
    end
  end
end
