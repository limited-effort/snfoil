# frozen_string_literal: true

require 'ostruct'
require 'pundit'
require 'spec_helper'

require_relative '../shared_contexts'

RSpec.describe SnFoil::CRUD::SetupContext do
  subject(:including_class) { SetupContextClass.clone }

  include_context 'with fake policy'

  describe '#self.model' do
    before { including_class.model(model_double) }

    it 'sets the internal model class' do
      expect(including_class.snfoil_model).to eq(model_double)
    end
  end

  describe '#self.policy' do
    before { including_class.policy(FakePolicy) }

    it 'sets the internal model class' do
      expect(including_class.snfoil_policy).to eq(FakePolicy)
    end
  end

  describe '#model' do
    before { including_class.model(model_double) }

    it 'returns the class internal model class' do
      expect(including_class.new.model).to eq(model_double)
    end
  end

  describe '#policy' do
    before { including_class.policy(model_double) }

    it 'returns the class internal policy class' do
      expect(including_class.new.policy).to eq(model_double)
    end
  end

  describe '#scope' do
    let(:entity) { double }
    let(:instance) { including_class.new(entity) }

    before do
      including_class.model(model_double)
      including_class.policy(policy)
    end

    it 'returns the policy\'s scope' do
      expect(instance.scope).to be_a(FakePolicy::Scope)
    end

    it 'instantiates the scope with the entity' do
      expect(instance.scope.entity).to be(entity)
    end
  end

  describe '#wrap_object' do
    context 'when adapter is configured' do
      it 'returns an orm wrapped object' do
        expect(including_class.new.wrap_object(OpenStruct.new).class.ancestors)
          .to include SnFoil::Adapters::ORMs::BaseAdapter
      end
    end

    context 'when adapter isn\'t configured' do
      before do
        allow(SnFoil).to receive(:adapter).and_return(nil)
      end

      it 'returns the object' do
        expect(including_class.new.wrap_object(OpenStruct.new).class.ancestors)
          .not_to include SnFoil::Adapters::ORMs::BaseAdapter
      end
    end
  end

  describe '#unwrap_object' do
    context 'when it is passed a wrapped object' do
      it 'returns the object' do
        original_object = FakeSuccessORMAdapter.new(OpenStruct.new)
        unwrapped_object = including_class.new.unwrap_object(original_object)

        expect(original_object.class.ancestors).to include SnFoil::Adapters::ORMs::BaseAdapter
        expect(unwrapped_object.class.ancestors).not_to include SnFoil::Adapters::ORMs::BaseAdapter
      end
    end

    context 'when it is passed a non wrapped object' do
      it 'returns the object' do
        original_object = OpenStruct.new
        unwrapped_object = including_class.new.unwrap_object(original_object)

        expect(unwrapped_object.class.ancestors).to eq original_object.class.ancestors
      end
    end
  end

  describe '#adapter?' do
    context 'when an adapter is configured' do
      it 'returns true for a wrapped object' do
        expect(including_class.new.adapter?(FakeSuccessORMAdapter.new(OpenStruct.new))).to be true
      end

      it 'returns false for a non-wrapped object' do
        expect(including_class.new.adapter?(OpenStruct.new)).to be false
      end
    end

    context 'when an adapter isn\'t configured' do
      before do
        allow(SnFoil).to receive(:adapter).and_return(nil)
      end

      it 'returns false for a wrapped object' do
        expect(including_class.new.adapter?(FakeSuccessORMAdapter.new(OpenStruct.new))).to be false
      end

      it 'returns false for a non-wrapped object' do
        expect(including_class.new.adapter?(OpenStruct.new)).to be false
      end
    end
  end

  describe '#adapter' do
    it 'returns the SnFoil adapter' do
      expect(including_class.new.adapter).to eq FakeSuccessORMAdapter
    end
  end
end

class SetupContextClass
  include SnFoil::CRUD::SetupContext
end
