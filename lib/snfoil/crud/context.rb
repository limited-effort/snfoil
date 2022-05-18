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

require 'active_support/concern'

require_relative 'build_context'
require_relative 'index_context'
require_relative 'show_context'
require_relative 'create_context'
require_relative 'update_context'
require_relative 'destroy_context'

module SnFoil
  module CRUD
    module Context
      extend ActiveSupport::Concern

      included do
        include ::SnFoil::CRUD::BuildContext
        include ::SnFoil::CRUD::IndexContext
        include ::SnFoil::CRUD::ShowContext
        include ::SnFoil::CRUD::CreateContext
        include ::SnFoil::CRUD::UpdateContext
        include ::SnFoil::CRUD::DestroyContext
      end
    end
  end
end
