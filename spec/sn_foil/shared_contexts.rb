# frozen_string_literal: true

require 'ostruct'
require 'dry-struct'
require 'sn_foil/policy'
require 'sn_foil/adapters/orms/base_adapter'

RSpec.shared_context('with fake entity') do
  let(:entity) { OpenStruct.new } # rubocop:disable Style/OpenStructUse -- reason: legacy support and its a test double
end

RSpec.shared_context('with fake model') do
  let(:model_double) { Person }
  let(:model_instance_double) { Person.new(first_name: 'Test', last_name: 'Person') }
  let(:relation_double) { double }

  before do
    allow(model_double).to receive_messages(new: model_instance_double, all: relation_double)
    allow(relation_double).to receive(:find).and_return(model_instance_double)
    allow(SnFoil).to receive(:adapter).and_return(FakeSuccessORMAdapter)
  end
end

RSpec.shared_context('with fake policy') do
  include_context 'with fake model'
  include_context 'with fake entity'

  let(:policy) { FakePolicy }
  let(:policy_double) { FakePolicy.new(model_double, entity) }
  let(:policy_scope) { FakePolicy::Scope }
  let(:policy_success) { true }

  before do
    policy.response = policy_success
    allow(policy).to receive(:new).and_return(policy_double)
    %i[index? show? create? update? destroy?].each { |a| allow(policy_double).to(receive(a).and_call_original) }
  end
end

class FakeSuccessORMAdapter < SnFoil::Adapters::ORMs::BaseAdapter
  def new(*params)
    self.class.new(__getobj__.new(*params))
  end

  def all
    __getobj__.all
  end

  def save # rubocop:disable Naming/PredicateMethod -- reason: legacy support
    true
  end

  def destroy # rubocop:disable Naming/PredicateMethod -- reason: legacy support
    true
  end

  def attributes=(attributes)
    if attributes.nil? || (attributes.is_a?(Hash) && attributes.empty?)
      self.class.new({})
    else
      self.class.new(**__getobj__.attributes, **attributes)
    end
  end
end

class FakeFailureORMAdapter < FakeSuccessORMAdapter
  def save # rubocop:disable Naming/PredicateMethod -- reason: legacy support
    false
  end

  def destroy # rubocop:disable Naming/PredicateMethod -- reason: legacy support
    false
  end
end

class FakePolicy
  include SnFoil::Policy

  def self.response=(resp) # rubocop:disable Style/TrivialAccessors
    @response = resp
  end

  def self.response
    @response || true
  end

  def response
    self.class.response
  end

  alias index? response
  alias show? response
  alias create? response
  alias update? response
  alias destroy? response
end

module Types
  include Dry.Types()
end

class Person < Dry::Struct
  attribute :first_name, Types::String.optional
  attribute :last_name, Types::String.optional

  def self.all; end
end
