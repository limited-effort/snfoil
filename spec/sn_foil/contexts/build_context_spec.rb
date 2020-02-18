# frozen_string_literal: true

require 'spec_helper'
require 'sn_foil/contexts/build_context'
require 'ostruct'
require_relative '../shared_contexts'

RSpec.describe SnFoil::Contexts::BuildContext do
  include_context 'with fake user'
  include_context 'with fake model'

  let(:including_class) { Class.new BuildContextClass }
  let(:instance) { including_class.new(user) }

  before do
    including_class.model(model_double)
    allow(model_double).to receive(:new).and_return(model_instance_double)
  end

  describe 'self#build' do
    let(:instance) { instance_double(including_class) }

    before do
      allow(including_class).to receive(:build).and_call_original
      allow(including_class).to receive(:new).and_return(instance)
      allow(instance).to receive(:build)
    end

    it 'instantiates a new instance of the class and calls build' do
      including_class.build(params: {})
      expect(including_class).to have_received(:new).once
      expect(instance).to have_received(:build).once
    end
  end

  describe '#setup_build_object' do
    context 'with options[:object]' do
      it 'directly returns any object provided in the options' do
        object = instance_double(OpenStruct)
        expect(instance.setup_build_object(params: {}, object: object)).to eq object
      end
    end

    context 'with options[:model]' do
      let(:other_model_double) { class_double(OpenStruct) }
      let(:other_model_instance_double) { instance_double(OpenStruct) }

      before do
        allow(other_model_double).to receive(:new).and_return(other_model_instance_double)
      end

      it 'instantiates an object using the options model class' do
        expect(instance.setup_build_object(params: {}, model: other_model_double)[:object]).to eq other_model_instance_double
        expect(other_model_double).to have_received(:new)
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
    before do
      allow(instance).to receive(:setup_build_object).and_call_original
      allow(instance).to receive(:setup_change).and_call_original
      allow(instance).to receive(:setup_build).and_call_original
      instance.build(params: {})
    end

    it 'calls #setup_build' do
      expect(instance).to have_received(:setup_build)
    end

    it 'calls #setup_change' do
      expect(instance).to have_received(:setup_change)
    end

    it 'calls #setup_build_object' do
      expect(instance).to have_received(:setup_build_object)
    end

    it 'sets an action in the options' do
      expect(instance).to have_received(:setup_build_object).with(hash_including(action: :build))
    end

    it 'returns the built object' do
      expect(instance.build(params: {})).to eq model_instance_double
    end
  end
end

class BuildContextClass
  include SnFoil::Contexts::BuildContext
end
