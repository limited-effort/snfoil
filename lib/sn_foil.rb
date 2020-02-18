# frozen_string_literal: true

require 'logger'
require 'active_support/core_ext/module/attribute_accessors'
require 'sn_foil/contexts/build_context'
require 'sn_foil/contexts/index_context'
require 'sn_foil/contexts/show_context'
require 'sn_foil/contexts/create_context'
require 'sn_foil/contexts/update_context'
require 'sn_foil/contexts/destroy_context'
require 'sn_foil/context'
require 'sn_foil/policy'
require 'sn_foil/searcher'
require 'sn_foil/version'

module SnFoil
  class Error < StandardError; end

  mattr_accessor :orm, default: 'active_record'
  mattr_writer :logger

  class << self
    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = name
      end
    end

    def adapter
      return @adapter if @adapter

      @adapter ||= if orm.instance_of?(String) || orm.instance_of?(Symbol)
                     if Object.const_defined?("SnFoil::Adapters::ORMs::#{orm.camelcase}")
                       "SnFoil::Adapters::ORMs::#{orm.camelcase}".constantize
                     else
                       orm.constantize
                     end
                   else
                     orm
                   end
    end

    def configure
      yield self
    end
  end
end
