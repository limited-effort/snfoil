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
require 'snfoil/context'
require_relative './setup_context'

module SnFoil
  module CRUD
    module BuildContext
      extend ActiveSupport::Concern

      included do
        include SetupContext

        interval :setup_build

        setup_build do |**options|
          params = options.fetch(:params, {})
          options[:object] ||= options.fetch(:model) { model }.new

          wrap_object(options[:object]).attributes = params

          options
        end
      end

      def build(**options)
        options[:action] = :build
        options = run_interval(:setup, **options)
        options = run_interval(:setup_build, **options)
        options[:object]
      end
    end
  end
end
