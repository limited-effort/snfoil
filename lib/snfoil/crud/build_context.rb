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
        interval :before_build

        setup_build do |**options|
          next options if options[:object]

          options[:object] ||= if options[:id]
                                 scope.resolve.find(options[:id])
                               else
                                 options.fetch(:model) { model }.new
                               end

          options
        end

        before_build do |**options|
          wrap_object(options[:object]).attributes = options.fetch(:params) { {} }

          options
        end

        def build(**options)
          options[:action] = :build
          options = run_interval(:setup, **options)
          options = run_interval(:setup_build, **options)
          run_interval(:before_build, **options)
        end
      end
    end
  end
end
