# frozen_string_literal: true

require 'active_support/concern'
require_relative 'contexts/build_context'
require_relative 'contexts/index_context'
require_relative 'contexts/show_context'
require_relative 'contexts/create_context'
require_relative 'contexts/update_context'
require_relative 'contexts/destroy_context'

module SnFoil
  module Context
    extend ActiveSupport::Concern

    included do
      include Contexts::BuildContext
      include Contexts::IndexContext
      include Contexts::ShowContext
      include Contexts::CreateContext
      include Contexts::UpdateContext
      include Contexts::DestroyContext
    end
  end
end
