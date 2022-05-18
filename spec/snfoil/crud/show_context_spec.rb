# frozen_string_literal: true

require 'spec_helper'
require_relative '../shared_contexts'

RSpec.describe SnFoil::CRUD::ShowContext do
  include_context 'with fake policy'
  let(:including_class) { ShowContextClass.clone }

  let(:instance) { including_class.new(entity: entity) }

  before do
    including_class.model(model_double)
    including_class.policy(policy)
  end

  describe 'predefined hooks' do
    it 'requires either an object or id provided' do
      expect do
        instance.show
      end.to raise_error ArgumentError
    end

    context 'with options[:object]' do
      it 'directly returns any object provided in the options' do
        object = instance_double(model_double)
        expect(instance.show(object: object)[:object]).to eq object
      end
    end

    context 'with options[:id]' do
      it 'calls find on the context\'s policy class scope' do
        id = 1
        instance.show(id: id)
        expect(relation_double).to have_received(:find).with(id).once
      end
    end

    context 'with options[:object] and options[:id]' do
      it 'directly returns any object provided in the options' do
        id = 1
        object = instance_double(model_double)
        expect(instance.show(id: id, object: object)[:object]).to eq object
        expect(relation_double).not_to have_received(:find)
      end
    end
  end

  describe '#show' do
    let(:allowed) { true }

    it 'calls #setup' do
      allow(instance).to receive(:setup).and_call_original
      instance.show(id: 1)
      expect(instance).to have_received(:setup).once
    end

    it 'finds the object' do
      instance.show(id: 1)
      expect(relation_double).to have_received(:find).once
    end

    it 'returns the object' do
      expect(instance.show(id: 1)[:object]).to eq(model_instance_double)
    end

    it 'authorizes the object' do
      instance.show(id: 1)
      expect(policy_double).to have_received(:show?).twice
    end
  end
end

class ShowContextClass
  include SnFoil::CRUD::ShowContext
end
