# frozen_string_literal: true

require 'spec_helper'
require 'sn_foil/contexts/setup_context_concern'
require_relative '../shared_contexts'
require 'pundit'

RSpec.describe SnFoil::Contexts::SetupContextConcern do
  include_context 'with fake policy'
  let(:including_class) { Class.new SetupContextClass }

  describe '#self.model_class' do
    before { including_class.model_class(model_double) }

    it 'sets the internal model class' do
      expect(including_class.i_model_class).to eq(model_double)
    end
  end

  describe '#self.policy_class' do
    before { including_class.policy_class(FakePolicy) }

    it 'sets the internal model class' do
      expect(including_class.i_policy_class).to eq(FakePolicy)
    end
  end

  describe '#model_class' do
    before { including_class.model_class(model_double) }

    it 'returns the class internal model class' do
      expect(including_class.new.model_class).to eq(model_double)
    end
  end

  describe '#policy_class' do
    before { including_class.policy_class(model_double) }

    it 'returns the class internal policy class' do
      expect(including_class.new.policy_class).to eq(model_double)
    end
  end

  describe '#authorize' do
    let(:user) { double }
    let(:instance) { including_class.new(user) }
    let(:action) { :create? }

    before do
      including_class.model_class(model_double)
      including_class.policy_class(FakePolicy)
    end

    context 'when there is no user in the context' do
      let(:user) { nil }

      it 'returns nil' do
        allow(FakePolicy).to receive(:new).and_call_original
        expect(instance.authorize(model_double, action)).to be_nil
        expect(FakePolicy).not_to have_received(:new)
        expect(policy_double).not_to have_received(action)
      end
    end

    context 'when a policy is provided in the context options' do
      let(:other_policy) { class_double(policy) }
      let(:other_policy_double) { instance_double(policy) }

      before do
        allow(other_policy).to receive(:new).and_return(other_policy_double)
        allow(other_policy_double).to receive(action).and_return(false)
      end

      it 'calls the policy from the options' do
        expect(instance.authorize(model_double, action, policy: other_policy)).to eq false
        expect(policy_double).not_to have_received(action)
        expect(other_policy).to have_received(:new).with(user, model_double)
        expect(other_policy_double).to have_received(action)
      end
    end

    context 'when the context has a policy_class configured' do
      it 'calls the policy from the context' do
        expect(instance.authorize(model_double, action)).to eq true
        expect(policy).to have_received(:new).with(user, model_double)
        expect(policy_double).to have_received(action)
      end
    end

    context 'with a user, no options, and no context' do
      before do
        including_class.policy_class(nil)
        allow(Pundit).to receive(:policy!).and_return(policy_double)
      end

      it 'lookups the policy through pundit' do
        expect(instance.authorize(model_double, action)).to eq true
        expect(policy_double).to have_received(action)
        expect(Pundit).to have_received(:policy!).with(user, model_double)
      end
    end
  end

  describe '#scope' do
    let(:user) { double }
    let(:instance) { including_class.new(user) }

    before do
      including_class.model_class(model_double)
      including_class.policy_class(policy)
    end

    it 'returns the policy\'s scope' do
      expect(instance.scope).to be_a(FakePolicy::Scope)
    end

    it 'instantiates the scope with the user' do
      expect(instance.scope.entity).to be(user)
    end
  end
end

class SetupContextClass
  include SnFoil::Contexts::SetupContextConcern
end
