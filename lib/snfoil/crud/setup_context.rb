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

require 'snfoil/context'

require 'active_support/concern'
require 'active_support/core_ext/string/inflections'

module SnFoil
  module CRUD
    module SetupContext
      extend ActiveSupport::Concern

      included do
        include SnFoil::Context

        interval :setup

        authorize do |**options|
          authentication_policy = options.fetch(:policy) { policy }
          authentication_action = options.fetch(:authorize) { "#{options[:action]}?" }
          next true if authentication_policy.new(entity, options[:object], **options).send(authentication_action)

          raise SnFoil::AuthorizationError,
                "#{entity ? entity&.class : 'Unknown'}: #{entity&.id} is not allowed to #{authentication_action} on #{authentication_policy}"
        end
      end

      class_methods do
        attr_reader :snfoil_model, :snfoil_policy, :snfoil_searcher

        def searcher(klass = nil)
          @snfoil_searcher = klass
        end

        def model(klass = nil)
          @snfoil_model = klass
        end

        def policy(klass = nil)
          @snfoil_policy = klass
        end
      end

      def model
        self.class.snfoil_model
      end

      def policy
        self.class.snfoil_policy
      end

      def scope
        "#{policy.name}::Scope".safe_constantize.new(entity, wrap_object(model))
      end

      def wrap_object(object)
        return object unless adapter

        adapter.new(object)
      end

      def unwrap_object(object)
        return object unless adapter

        adapter?(object) ? object.__getobj__ : object
      end

      def adapter?(object)
        return false unless adapter

        object.instance_of? adapter
      end

      def adapter
        @adapter ||= SnFoil.adapter
      end
    end
  end
end
