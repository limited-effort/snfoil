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
require_relative './change_context'

module SnFoil
  module Contexts
    module DestroyContext
      extend ActiveSupport::Concern

      included do
        include SetupContext
        include ChangeContext

        action :destroy, with: :destroy_action

        setup_destroy { |options| run_interval(:setup, **options) }
        setup_destroy { |options| run_interval(:setup_change, **options) }
        before_destroy { |options| run_interval(:before_change, **options) }
        after_destroy_success { |options| run_interval(:after_change_success, **options) }
        after_destroy_failure { |options| run_interval(:after_change_failure, **options) }
        after_destroy { |options| run_interval(:after_change, **options) }

        setup do |options|
          raise ArgumentError, 'one of the following keywords is required: id, object' unless options[:id] || options[:object]

          options
        end

        before_destroy do |options|
          options[:object] ||= scope.resolve.find(options[:id])

          options
        end
      end

      def destroy_action(options)
        wrap_object(options[:object]).destroy
      end
    end
  end
end
