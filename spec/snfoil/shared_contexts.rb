# frozen_string_literal: true

require 'ostruct'
require 'dry-struct'

RSpec.shared_context('with fake entity') do
  let(:entity) { double }
end

RSpec.shared_context('with fake model') do
  let(:model_double) { Person }
  let(:model_instance_double) { Person.new(id: 1, first_name: 'Test', last_name: 'Person') }
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

  def save
    true
  end

  def destroy
    true
  end

  def attributes=(attributes)
    __getobj__.class.new(**__getobj__.attributes, **attributes)
  end
end

class FakeFailureORMAdapter < FakeSuccessORMAdapter
  def save
    false
  end

  def destroy
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
  alias build? response

  class Scope < Scope
    def resolve
      scope.all
    end
  end
end

module Types
  include Dry.Types()
end

class Person < Dry::Struct
  attribute :id, Types::Integer.optional
  attribute :first_name, Types::String.optional
  attribute :last_name, Types::String.optional

  def self.all; end
end
