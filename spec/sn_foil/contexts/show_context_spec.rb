# frozen_string_literal: true

require 'spec_helper'
require 'sn_foil/contexts/show_context'
require_relative '../shared_contexts'

RSpec.describe SnFoil::Contexts::ShowContext do
  include_context 'with fake policy'
  let(:including_class) { Class.new ShowContextClass }

  let(:instance) { including_class.new(entity) }

  before do
    including_class.model(model_double)
    including_class.policy(policy)
  end

  describe 'self#show' do
    let(:instance) { instance_double(including_class) }

    before do
      allow(including_class).to receive(:show).and_call_original
      allow(including_class).to receive(:new).and_return(instance)
      allow(instance).to receive(:show)
    end

    it 'instantiates a new instance of the class and calls show' do
      including_class.show(id: 1)
      expect(including_class).to have_received(:new).once
      expect(instance).to have_received(:show).once
    end
  end

  describe '#setup_show_object' do
    it 'requires either an object or id provided' do
      expect do
        instance.setup_show_object
      end.to raise_error ArgumentError
    end

    context 'with options[:object]' do
      it 'directly returns any object provided in the options' do
        object = instance_double(model_double)
        expect(instance.setup_show_object(object: object)[:object]).to eq object
      end
    end

    context 'with options[:id]' do
      it 'calls find on the context\'s policy class scope' do
        id = 1
        instance.setup_show_object(id: id)
        expect(relation_double).to have_received(:find).with(id).once
      end
    end

    context 'with options[:object] and options[:id]' do
      it 'directly returns any object provided in the options' do
        id = 1
        object = instance_double(model_double)
        expect(instance.setup_show_object(id: id, object: object)[:object]).to eq object
        expect(relation_double).not_to have_received(:find)
      end
    end
  end

  describe '#show' do
    let(:allowed) { true }

    it 'sets an action in the options' do
      allow(instance).to receive(:setup_show_object).and_call_original
      instance.show(id: 1)
      expect(instance).to have_received(:setup_show_object).with(hash_including(action: :show))
    end

    it 'calls #setup' do
      allow(instance).to receive(:setup).and_call_original
      instance.show(id: 1)
      expect(instance).to have_received(:setup).once
    end

    it 'calls #setup_show' do
      allow(instance).to receive(:setup_show).and_call_original
      instance.show(id: 1)
      expect(instance).to have_received(:setup_show)
    end

    it 'calls #setup_show_object' do
      allow(instance).to receive(:setup_show_object).and_call_original
      instance.show(id: 1)
      expect(instance).to have_received(:setup_show_object)
    end

    it 'finds the object' do
      instance.show(id: 1)
      expect(relation_double).to have_received(:find).once
    end

    it 'returns the object' do
      expect(instance.show(id: 1)).to eq(model_instance_double)
    end

    it 'authorizes the object' do
      instance.show(id: 1)
      expect(policy_double).to have_received(:show?).once
    end
  end
end

class ShowContextClass
  include SnFoil::Contexts::ShowContext
end
