# frozen_string_literal: true

require 'spec_helper'
require_relative '../shared_contexts'
require 'ostruct'

RSpec.describe SnFoil::Contexts::CreateContext do
  include_context 'with fake policy'
  let(:including_class) { CreateContextClass.clone }

  let(:instance) { including_class.new(entity) }
  let(:entity) { double }
  let(:params) { {} }
  let(:canary) { Canary.new }

  before do
    including_class.model(model_double)
    including_class.policy(policy)
  end

  describe '#create' do
    context 'with options[:object]' do
      it 'directly returns any object provided in the options' do
        object = double
        allow(object).to receive(:attributes).and_return({})
        expect(instance.create(params: {}, object: object)[:object]).to eq object
      end
    end

    context 'with options[:model]' do
      let(:other_model_double) { Person }
      let(:other_model_instance_double) { other_model_double.new(first_name: 'Other', last_name: 'Human') }

      before do
        allow(other_model_double).to receive(:new).and_return(other_model_instance_double)
      end

      it 'instantiates an object using the options model class' do
        expect(instance.create(params: {}, model: other_model_double)[:object]).to eq other_model_instance_double
        expect(other_model_double).to have_received(:new).exactly(3).times
      end
    end

    context 'without options[:model]' do
      it 'instantiates an object using the contexts model class' do
        expect(instance.create(params: {})[:object]).to eq(model_instance_double)
        expect(model_double).to have_received(:new).twice
      end
    end
  end

  describe 'predefined hooks' do
    it 'calls setup before setup_build' do
      instance.create(params: {}, canary: canary)
      index = canary.song.index { |s| s[:data] == :setup }
      expect(canary.song[index + 1][:data]).to eq :setup_build
    end

    it 'calls setup_build before setup_change' do
      instance.create(params: {}, canary: canary)
      index = canary.song.index { |s| s[:data] == :setup_build }
      expect(canary.song[index + 1][:data]).to eq :setup_change
    end

    it 'calls setup_change before setup_create' do
      instance.create(params: {}, canary: canary)
      index = canary.song.index { |s| s[:data] == :setup_change }
      expect(canary.song[index + 1][:data]).to eq :setup_create
    end

    it 'calls before_change before before_create' do
      instance.create(params: {}, canary: canary)
      index = canary.song.index { |s| s[:data] == :before_change }
      expect(canary.song[index + 1][:data]).to eq :before_create
    end

    it 'calls after_change_success before after_create_success' do
      instance.create(params: {}, canary: canary)
      index = canary.song.index { |s| s[:data] == :after_change_success }
      expect(canary.song[index + 1][:data]).to eq :after_create_success
    end

    it 'calls after_change_failure before after_create_failure' do
      allow(SnFoil).to receive(:adapter).and_return(FakeFailureORMAdapter)
      instance.create(params: {}, canary: canary)
      index = canary.song.index { |s| s[:data] == :after_change_failure }
      expect(canary.song[index + 1][:data]).to eq :after_create_failure
    end

    it 'calls after_change before after_create' do
      instance.create(params: {}, canary: canary)
      index = canary.song.index { |s| s[:data] == :after_change }
      expect(canary.song[index + 1][:data]).to eq :after_create
    end
  end
end

class CreateContextClass
  include SnFoil::Contexts::CreateContext

  setup do |opts|
    opts[:canary]&.sing(:setup)
    opts
  end

  setup_build do |opts|
    opts[:canary]&.sing(:setup_build)
    opts
  end

  setup_change do |opts|
    opts[:canary]&.sing(:setup_change)
    opts
  end

  setup_create do |opts|
    opts[:canary]&.sing(:setup_create)
    opts
  end

  before_create do |opts|
    opts[:canary]&.sing(:before_create)
    opts
  end

  before_change do |opts|
    opts[:canary]&.sing(:before_change)
    opts
  end

  after_create_success do |opts|
    opts[:canary]&.sing(:after_create_success)
    opts
  end

  after_change_success do |opts|
    opts[:canary]&.sing(:after_change_success)
    opts
  end

  after_create_failure do |opts|
    opts[:canary]&.sing(:after_create_failure)
    opts
  end

  after_change_failure do |opts|
    opts[:canary]&.sing(:after_change_failure)
    opts
  end

  after_create do |opts|
    opts[:canary]&.sing(:after_create)
    opts
  end

  after_change do |opts|
    opts[:canary]&.sing(:after_change)
    opts
  end
end
