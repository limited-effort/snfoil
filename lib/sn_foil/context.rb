# frozen_string_literal: true

require 'active_support/concern'
require_relative 'contexts/build_context_concern'
require_relative 'contexts/index_context_concern'
require_relative 'contexts/show_context_concern'
require_relative 'contexts/create_context_concern'
require_relative 'contexts/update_context_concern'
require_relative 'contexts/destroy_context_concern'

module SnFoil
  module Context
    extend ActiveSupport::Concern

    included do
      include BuildContextConcern
      include IndexContextConcern
      include ShowContextConcern
      include CreateContextConcern
      include UpdateContextConcern
      include DestroyContextConcern
    end
  end
end
