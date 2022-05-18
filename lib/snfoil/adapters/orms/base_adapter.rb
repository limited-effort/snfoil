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

require 'delegate'

module SnFoil
  module Adapters
    module ORMs
      class BaseAdapter < SimpleDelegator
        def new(**_params)
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

        def attributes=(_attributes)
          raise NotImplementedError, '#attributes= not implemented in adapter'
        end

        def is_a?(check_class)
          __getobj__.class.object_id.equal?(check_class.object_id)
        end

        def klass
          __getobj__.class
        end
      end
    end
  end
end
