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
require_relative './setup_context'

module SnFoil
  module CRUD
    module ChangeContext
      extend ActiveSupport::Concern

      included do
        include SetupContext

        intervals :setup_change, :before_change, :after_change, :after_change_success, :after_change_failure

        setup_change do |options|
          options[:pre_change_context_params] ||= options[:params]
          options[:params] = options[:params].select { |params| self.class.i_params.include?(params) } if self.class.i_params

          options
        end
      end

      class_methods do
        attr_reader :i_params

        def params(*permitted_params)
          @i_params ||= []
          @i_params |= permitted_params
        end
      end
    end
  end
end
