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
    module IndexContext
      extend ActiveSupport::Concern

      included do
        include SetupContext

        action :index, with: :index_action

        setup_index { |**options| run_interval(:setup, **options) }

        setup_index do |**options|
          options[:object] ||= options.fetch(:searcher) { self.class.snfoil_searcher }
                                      .new(scope: options.fetch(:scope) { scope.resolve })
                                      .search(options.fetch(:params) { {} })

          options
        end

        def index_action(**options)
          options[:object]
        end
      end
    end
  end
end
