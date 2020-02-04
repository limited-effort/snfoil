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
      include Contexts::BuildContextConcern
      include Contexts::IndexContextConcern
      include Contexts::ShowContextConcern
      include Contexts::CreateContextConcern
      include Contexts::UpdateContextConcern
      include Contexts::DestroyContextConcern
    end
  end
end
