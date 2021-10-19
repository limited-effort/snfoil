# frozen_string_literal: true

require 'spec_helper'
require_relative '../shared_contexts'

RSpec.describe SnFoil::CRUD::UpdateContext do
  include_context 'with fake policy'
  let(:including_class) { UpdateContextClass.clone }

  let(:instance) { including_class.new(entity) }
  let(:params) { { first_name: 'John', last_name: 'Doe' } }
  let(:canary) { Canary.new }

  before do
    including_class.model(model_double)
    including_class.policy(policy)
  end

  describe '#update' do
    context 'without options[:id] or options[:object]' do
      it 'raises an error' do
        expect do
          instance.update(params: {})
        end.to raise_error ArgumentError
      end
    end

    context 'with options[:object]' do
      let(:object) { Person.new(first_name: nil, last_name: nil) }

      it 'operates on any object provided in the options' do
        expect(instance.update(params: {}, object: object)[:object]).to eq object
      end

      it 'updates the attributes of any object provided in the options' do
        allow(object).to receive(:attributes).and_call_original
        instance.update(params: {}, object: object)
        expect(object).to have_received(:attributes).once
      end
    end

    context 'with options[:id]' do
      it 'lookups the object in the scope' do
        expect(instance.update(params: {}, id: 1)[:object]).to eq model_instance_double
        expect(relation_double).to have_received(:find).once
      end

      it 'updates the attributes of any object provided in the options' do
        allow(model_instance_double).to receive(:attributes).and_call_original
        instance.update(params: {}, id: 1)
        expect(model_instance_double).to have_received(:attributes).once
      end
    end
  end

  describe 'predefined hooks' do
    it 'calls setup before setup_change' do
      instance.update(id: 1, params: {}, canary: canary)
      index = canary.song.index { |s| s[:data] == :setup }
      expect(canary.song[index + 1][:data]).to eq :setup_change
    end

    it 'calls setup_change before setup_update' do
      instance.update(id: 1, params: {}, canary: canary)
      index = canary.song.index { |s| s[:data] == :setup_change }
      expect(canary.song[index + 1][:data]).to eq :setup_update
    end

    it 'calls before_change before before_update' do
      instance.update(id: 1, params: {}, canary: canary)
      index = canary.song.index { |s| s[:data] == :before_change }
      expect(canary.song[index + 1][:data]).to eq :before_update
    end

    it 'calls after_change_success before after_update_success' do
      instance.update(id: 1, params: {}, canary: canary)
      index = canary.song.index { |s| s[:data] == :after_change_success }
      expect(canary.song[index + 1][:data]).to eq :after_update_success
    end

    it 'calls after_change_failure before after_update_failure' do
      allow(SnFoil).to receive(:adapter).and_return(FakeFailureORMAdapter)
      instance.update(id: 1, params: {}, canary: canary)
      index = canary.song.index { |s| s[:data] == :after_change_failure }
      expect(canary.song[index + 1][:data]).to eq :after_update_failure
    end

    it 'calls after_change before after_update' do
      instance.update(id: 1, params: {}, canary: canary)
      index = canary.song.index { |s| s[:data] == :after_change }
      expect(canary.song[index + 1][:data]).to eq :after_update
    end
  end
end

class UpdateContextClass
  include SnFoil::CRUD::UpdateContext

  setup do |opts|
    opts[:canary]&.sing(:setup)
    opts
  end

  setup_change do |opts|
    opts[:canary]&.sing(:setup_change)
    opts
  end

  setup_update do |opts|
    opts[:canary]&.sing(:setup_update)
    opts
  end

  before_update do |opts|
    opts[:canary]&.sing(:before_update)
    opts
  end

  before_change do |opts|
    opts[:canary]&.sing(:before_change)
    opts
  end

  after_update_success do |opts|
    opts[:canary]&.sing(:after_update_success)
    opts
  end

  after_change_success do |opts|
    opts[:canary]&.sing(:after_change_success)
    opts
  end

  after_update_failure do |opts|
    opts[:canary]&.sing(:after_update_failure)
    opts
  end

  after_change_failure do |opts|
    opts[:canary]&.sing(:after_change_failure)
    opts
  end

  after_update do |opts|
    opts[:canary]&.sing(:after_update)
    opts
  end

  after_change do |opts|
    opts[:canary]&.sing(:after_change)
    opts
  end
end
