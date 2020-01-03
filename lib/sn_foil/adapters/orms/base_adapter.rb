# frozen_string_literal: true

module SnFoil
  module Adapters
    module ORMs
      class BaseAdapter < SimpleDelegator
        def new(*_params)
          raise NotImplementedError, '#new not implemented in adapter'
        end

        def all
          raise NotImplementedError, '#all not implemented in adapter'
        end

        def save
          raise NotImplementedError, '#save not implemented in adapter'
        end

        def destroy
          raise NotImplementedError, '#destroy not implemented in adapter'
        end

        def attributes=(**_attributes)
          raise NotImplementedError, '#attributes= not implemented in adapter'
        end
      end
    end
  end
end
