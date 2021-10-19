# frozen_string_literal: true

require 'ostruct'
require 'spec_helper'

require_relative '../shared_contexts'

RSpec.describe SnFoil::CRUD::BuildContext do
  subject(:including_class) { BuildContextClass.clone }

  include_context 'with fake policy'

  let(:instance) { including_class.new(entity) }
  let(:entity) { double }
  let(:arguments) { { canary: canary, params: params } }
  let(:params) { {} }
  let(:canary) { Canary.new }

  before do
    including_class.model(model_double)
    including_class.policy(policy)
  end

  describe '#build' do
    it 'sets an action in the options' do
      allow(instance).to receive(:setup_build).and_call_original
      instance.build(**arguments)
      expect(instance).to have_received(:setup_build).with(hash_including(action: :build))
    end

    it 'does not authorize the object by default' do
      instance.build(**arguments)
      expect(policy).not_to have_received(:new).with(entity, FakeSuccessORMAdapter)
    end

    it 'calls #setup' do
      allow(instance).to receive(:setup).and_call_original
      instance.build(**arguments)
      expect(instance).to have_received(:setup).once
    end

    it 'calls #setup_build' do
      allow(instance).to receive(:setup_build).and_call_original
      instance.build(**arguments)
      expect(instance).to have_received(:setup_build).once
    end

    it 'returns the built object' do
      expect(instance.build(**arguments)).to eq model_instance_double
    end
  end

  describe 'predefined hooks' do
    context 'with options[:object]' do
      it 'directly returns any object provided in the options' do
        object = double
        allow(object).to receive(:attributes).and_return({})
        expect(instance.build(**arguments, object: object)).to eq object
      end
    end

    context 'with options[:model]' do
      let(:other_model_double) { Person }
      let(:other_model_instance_double) { other_model_double.new(first_name: 'Other', last_name: 'Human') }

      before do
        allow(other_model_double).to receive(:new).and_return(other_model_instance_double)
      end

      it 'instantiates an object using the options model class' do
        expect(instance.build(**arguments, model: other_model_double)).to eq other_model_instance_double
        expect(other_model_double).to have_received(:new).exactly(3).times
      end
    end

    context 'without options[:model]' do
      it 'instantiates an object using the contexts model class' do
        expect(instance.build(**arguments)).to eq(model_instance_double)
        expect(model_double).to have_received(:new).twice
      end
    end
  end

  context 'when hooks are provided' do
    describe 'self#setup' do
      it 'gets called first' do
        instance.build(**arguments, id: 1)
        expect(canary.song[0][:data]).to eq :setup
      end
    end

    describe 'self#setup_build' do
      it 'gets called after setup' do
        instance.build(**arguments, id: 1)
        expect(canary.song[0][:data]).to eq :setup
        expect(canary.song[1][:data]).to eq :setup_build
      end
    end
  end
end

class BuildContextClass
  include SnFoil::CRUD::BuildContext

  setup do |opts|
    opts[:canary]&.sing(:setup)
    opts
  end

  setup_build do |opts|
    opts[:canary]&.sing(:setup_build)
    opts
  end
end
