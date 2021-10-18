# frozen_string_literal: true

require 'spec_helper'
require_relative '../shared_contexts'
require 'ostruct'

RSpec.describe SnFoil::Contexts::DestroyContext do
  include_context 'with fake policy'
  let(:including_class) { DestroyContextClass.clone }

  let(:instance) { including_class.new(entity) }
  let(:entity) { double }
  let(:params) { {} }
  let(:canary) { Canary.new }

  before do
    including_class.model(model_double)
    including_class.policy(FakePolicy)
  end

  describe '#destroy' do
    context 'without options[:id] or options[:object]' do
      it 'raises an error' do
        expect do
          instance.destroy(params: {})
        end.to raise_error ArgumentError
      end
    end

    context 'with options[:object]' do
      it 'directly returns any object provided in the options' do
        object = instance_double(model_double)
        expect(instance.destroy(params: {}, object: object)[:object]).to eq object
      end
    end

    context 'with options[:id]' do
      let(:object) { instance_double(model) }

      it 'lookups the object in the scope' do
        expect(instance.destroy(params: {}, id: 1)[:object]).to eq model_instance_double
        expect(relation_double).to have_received(:find).once
      end
    end
  end

  describe 'predefined hooks' do
    it 'calls setup before setup_change' do
      instance.destroy(id: 1, params: {}, canary: canary)
      index = canary.song.index { |s| s[:data] == :setup }
      expect(canary.song[index + 1][:data]).to eq :setup_change
    end

    it 'calls setup_change before setup_destroy' do
      instance.destroy(id: 1, params: {}, canary: canary)
      index = canary.song.index { |s| s[:data] == :setup_change }
      expect(canary.song[index + 1][:data]).to eq :setup_destroy
    end

    it 'calls before_change before before_destroy' do
      instance.destroy(id: 1, params: {}, canary: canary)
      index = canary.song.index { |s| s[:data] == :before_change }
      expect(canary.song[index + 1][:data]).to eq :before_destroy
    end

    it 'calls after_change_success before after_destroy_success' do
      instance.destroy(id: 1, params: {}, canary: canary)
      index = canary.song.index { |s| s[:data] == :after_change_success }
      expect(canary.song[index + 1][:data]).to eq :after_destroy_success
    end

    it 'calls after_change_failure before after_destroy_failure' do
      allow(SnFoil).to receive(:adapter).and_return(FakeFailureORMAdapter)
      instance.destroy(id: 1, params: {}, canary: canary)
      index = canary.song.index { |s| s[:data] == :after_change_failure }
      expect(canary.song[index + 1][:data]).to eq :after_destroy_failure
    end

    it 'calls after_change before after_destroy' do
      instance.destroy(id: 1, params: {}, canary: canary)
      index = canary.song.index { |s| s[:data] == :after_change }
      expect(canary.song[index + 1][:data]).to eq :after_destroy
    end
  end
end

class DestroyContextClass
  include SnFoil::Contexts::DestroyContext

  setup do |opts|
    opts[:canary]&.sing(:setup)
    opts
  end

  setup_change do |opts|
    opts[:canary]&.sing(:setup_change)
    opts
  end

  setup_destroy do |opts|
    opts[:canary]&.sing(:setup_destroy)
    opts
  end

  before_destroy do |opts|
    opts[:canary]&.sing(:before_destroy)
    opts
  end

  before_change do |opts|
    opts[:canary]&.sing(:before_change)
    opts
  end

  after_destroy_success do |opts|
    opts[:canary]&.sing(:after_destroy_success)
    opts
  end

  after_change_success do |opts|
    opts[:canary]&.sing(:after_change_success)
    opts
  end

  after_destroy_failure do |opts|
    opts[:canary]&.sing(:after_destroy_failure)
    opts
  end

  after_change_failure do |opts|
    opts[:canary]&.sing(:after_change_failure)
    opts
  end

  after_destroy do |opts|
    opts[:canary]&.sing(:after_destroy)
    opts
  end

  after_change do |opts|
    opts[:canary]&.sing(:after_change)
    opts
  end
end
