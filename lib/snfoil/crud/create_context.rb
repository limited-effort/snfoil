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
require_relative './change_context'

module SnFoil
  module CRUD
    module CreateContext
      extend ActiveSupport::Concern

      included do
        include BuildContext
        include ChangeContext

        action :create, with: :create_action

        setup_create { |options| run_interval(:setup, **options) }
        setup_create { |options| run_interval(:setup_build, **options) }
        setup_create { |options| run_interval(:setup_change, **options) }
        before_create { |options| run_interval(:before_change, **options) }
        after_create_success { |options| run_interval(:after_change_success, **options) }
        after_create_failure { |options| run_interval(:after_change_failure, **options) }
        after_create { |options| run_interval(:after_change, **options) }

        def create_action(options)
          wrap_object(options[:object]).save
        end
      end
    end
  end
end
