# frozen_string_literal: true

require 'spec_helper'
require 'sn_foil/contexts/build_context'
require 'ostruct'
require_relative '../shared_contexts'

RSpec.describe SnFoil::Contexts::BuildContext do
  include_context 'with fake policy'
  let(:including_class) { Class.new BuildContextClass }

  let(:instance) { including_class.new(entity) }
  let(:entity) { double }
  let(:params) { {} }

  before do
    including_class.model(model_double)
    including_class.policy(policy)
  end

  describe 'self#build' do
    let(:instance) { instance_double(including_class) }

    before do
      allow(including_class).to receive(:build).and_call_original
      allow(including_class).to receive(:new).and_return(instance)
      allow(instance).to receive(:build)
    end

    it 'instantiates a new instance of the class and calls build' do
      including_class.build(params: params)
      expect(including_class).to have_received(:new).once
      expect(instance).to have_received(:build).once
    end
  end

  describe '#setup_build_object' do
    context 'with options[:object]' do
      it 'directly returns any object provided in the options' do
        object = double
        allow(object).to receive(:attributes).and_return({})
        expect(instance.setup_build_object(params: {}, object: object)[:object]).to eq object
      end
    end

    context 'with options[:model]' do
      let(:other_model_double) { Person }
      let(:other_model_instance_double) { other_model_double.new(first_name: 'Other', last_name: 'Human') }

      before do
        allow(other_model_double).to receive(:new).and_return(other_model_instance_double)
      end

      it 'instantiates an object using the options model class' do
        expect(instance.setup_build_object(params: {}, model: other_model_double)[:object]).to eq other_model_instance_double
        expect(other_model_double).to have_received(:new).twice # Once for creation and once for attr assignment
      end
    end

    context 'without options[:model]' do
      it 'instantiates an object using the contexts model class' do
        expect(instance.setup_build_object(params: {})[:object]).to eq(model_instance_double)
        expect(model_double).to have_received(:new)
      end
    end
  end

  describe '#build' do
    it 'sets an action in the options' do
      allow(instance).to receive(:setup_build).and_call_original
      instance.build(params: params)
      expect(instance).to have_received(:setup_build).with(hash_including(action: :build))
    end

    it 'does not authorize the object by default' do
      instance.build(params: params)
      expect(policy).not_to have_received(:new).with(entity, FakeSuccessORMAdapter)
    end

    context 'when passed authorize in the options' do
      it 'authorizes the object' do
        instance.build(params: params, authorize: :create?)
        expect(policy).to have_received(:new).with(entity, FakeSuccessORMAdapter)
        expect(policy_double).to have_received(:create?).once
      end
    end

    it 'calls #setup' do
      allow(instance).to receive(:setup).and_call_original
      instance.build(params: params)
      expect(instance).to have_received(:setup).once
    end

    it 'calls #setup_build' do
      allow(instance).to receive(:setup_build).and_call_original
      instance.build(params: params)
      expect(instance).to have_received(:setup_build).once
    end

    it 'returns the built object' do
      expect(instance.build(params: params)).to eq model_instance_double
    end
  end

  context 'when hooks are provided' do
    let(:canary) { Canary.new }

    before do
      # Setup Action Hooks
      including_class.setup do |opts|
        opts[:canary].sing(:setup)
        opts
      end
      including_class.setup_build do |opts|
        opts[:canary].sing(:setup_build)
        opts
      end
    end

    describe 'self#setup' do
      it 'gets called first' do
        instance.build(params: params, id: 1, canary: canary)
        expect(canary.song[0][:data]).to eq :setup
      end
    end

    describe 'self#setup_build' do
      it 'gets called after setup' do
        instance.build(params: params, id: 1, canary: canary)
        expect(canary.song[0][:data]).to eq :setup
        expect(canary.song[1][:data]).to eq :setup_build
      end
    end
  end
end

class BuildContextClass
  include SnFoil::Contexts::BuildContext
end
