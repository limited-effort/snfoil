# frozen_string_literal: true

# Copyright 2021 Matthew Howes

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#   http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
