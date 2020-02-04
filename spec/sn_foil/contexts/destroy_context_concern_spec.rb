# frozen_string_literal: true

require 'spec_helper'
require 'sn_foil/contexts/destroy_context_concern'
require_relative '../shared_contexts'
require 'ostruct'

RSpec.describe SnFoil::Contexts::DestroyContextConcern do
  include_context 'with fake policy'
  let(:including_class) { Class.new DestroyContextClass }

  let(:instance) { including_class.new(user) }
  let(:user) { double }
  let(:params) { {} }

  before do
    including_class.model(model_double)
    including_class.policy(FakePolicy)
  end

  describe 'self#destroy' do
    let(:instance) { instance_double(including_class) }

    before do
      allow(including_class).to receive(:destroy).and_call_original
      allow(including_class).to receive(:new).and_return(instance)
      allow(instance).to receive(:destroy)
    end

    it 'instantiates a new instance of the class and calls destroy' do
      including_class.destroy(params: params, id: 1)
      expect(including_class).to have_received(:new).once
      expect(instance).to have_received(:destroy).once
    end
  end

  describe '#setup_destroy_object' do
    context 'without options[:id] or options[:object]' do
      it 'raises an error' do
        expect do
          instance.setup_destroy_object(params: {})
        end.to raise_error ArgumentError
      end
    end

    context 'with options[:object]' do
      it 'directly returns any object provided in the options' do
        object = instance_double(model_double)
        expect(instance.setup_destroy_object(params: {}, object: object)[:object]).to eq object
      end
    end

    context 'with options[:id]' do
      let(:object) { instance_double(model) }

      it 'lookups the object in the scope' do
        expect(instance.setup_destroy_object(params: {}, id: 1)[:object]).to eq model_instance_double
        expect(relation_double).to have_received(:find).once
      end
    end
  end

  describe '#destroy' do
    it 'sets an action in the options' do
      allow(instance).to receive(:setup_destroy).and_call_original
      instance.destroy(params: params, id: 1)
      expect(instance).to have_received(:setup_destroy).with(hash_including(action: :destroy))
    end

    it 'authorizes the object' do
      instance.destroy(params: params, id: 1)
      expect(policy).to have_received(:new).with(user, FakeSuccessORMAdapter)
      expect(policy_double).to have_received(:destroy?).once
    end

    it 'calls #setup_destroy' do
      allow(instance).to receive(:setup_destroy).and_call_original
      instance.destroy(params: params, id: 1)
      expect(instance).to have_received(:setup_destroy).once
    end

    it 'calls #before_destroy' do
      allow(instance).to receive(:before_destroy).and_call_original
      instance.destroy(params: params, id: 1)
      expect(instance).to have_received(:before_destroy).once
    end

    context 'when the destroy is successful' do
      it 'calls #after_destroy_success' do
        allow(instance).to receive(:after_destroy_success).and_call_original
        instance.destroy(params: params, id: 1)
        expect(instance).to have_received(:after_destroy_success).once
      end

      it 'calls #after_change_success' do
        allow(instance).to receive(:after_change_success).and_call_original
        instance.destroy(params: params, id: 1)
        expect(instance).to have_received(:after_change_success).once
      end
    end

    context 'when the destroy isn\'t successful' do
      before do
        allow(SnFoil).to receive(:adapter).and_return(FakeFailureORMAdapter)
      end

      it 'calls #after_destroy_failure' do
        allow(instance).to receive(:after_destroy_failure).and_call_original
        instance.destroy(params: params, id: 1)
        expect(instance).to have_received(:after_destroy_failure).once
      end

      it 'calls #after_change_failure' do
        allow(instance).to receive(:after_change_failure).and_call_original
        instance.destroy(params: params, id: 1)
        expect(instance).to have_received(:after_change_failure).once
      end
    end
  end

  context 'when hooks are provided' do
    let(:canary) { Canary.new }

    before do
      # Setup Action Hooks
      including_class.before_destroy do |opts|
        opts[:canary].sing(:before_destroy)
        opts
      end
      including_class.before_change do |opts|
        opts[:canary].sing(:before_change)
        opts
      end
      including_class.after_destroy_success do |opts|
        opts[:canary].sing(:after_destroy_success)
        opts
      end
      including_class.after_change_success do |opts|
        opts[:canary].sing(:after_change_success)
        opts
      end
      including_class.after_destroy_failure do |opts|
        opts[:canary].sing(:after_destroy_failure)
        opts
      end
      including_class.after_change_failure do |opts|
        opts[:canary].sing(:after_change_failure)
        opts
      end
      including_class.after_destroy do |opts|
        opts[:canary].sing(:after_destroy)
        opts
      end
      including_class.after_change do |opts|
        opts[:canary].sing(:after_change)
        opts
      end
    end

    describe 'self#before_destroy' do
      it 'gets called before any save' do
        instance.destroy(params: params, id: 1, canary: canary)
        expect(canary.song[0][:data]).to eq :before_destroy
        expect(canary.song[2][:data]).to eq :after_destroy_success
      end

      it 'gets called before :before_change' do
        instance.destroy(params: params, id: 1, canary: canary)
        expect(canary.song[0][:data]).to eq :before_destroy
        expect(canary.song[1][:data]).to eq :before_change
      end
    end

    describe 'self#before_change' do
      it 'gets called before any save' do
        instance.destroy(params: params, id: 1, canary: canary)
        expect(canary.song[1][:data]).to eq :before_change
        expect(canary.song[2][:data]).to eq :after_destroy_success
      end
    end

    describe 'self#after_destroy_success' do
      it 'gets called after a successful save' do
        instance.destroy(params: params, id: 1, canary: canary)
        expect(canary.song[2][:data]).to eq :after_destroy_success
        expect(canary.song.map { |x| x[:data] }).not_to include(:after_change_failure)
      end

      it 'gets called before after_destroy_success' do
        instance.destroy(params: params, id: 1, canary: canary)
        expect(canary.song[2][:data]).to eq :after_destroy_success
        expect(canary.song[3][:data]).to eq :after_change_success
      end
    end

    describe 'self#after_change_success' do
      it 'gets called after a successful save' do
        instance.destroy(params: params, id: 1, canary: canary)
        expect(canary.song[3][:data]).to eq :after_change_success
        expect(canary.song.map { |x| x[:data] }).not_to include(:after_change_failure)
      end
    end

    describe 'self#after_destroy_failure' do
      before do
        allow(SnFoil).to receive(:adapter).and_return(FakeFailureORMAdapter)
      end

      it 'gets called after a failed save' do
        instance.destroy(params: params, id: 1, canary: canary)
        expect(canary.song[2][:data]).to eq :after_destroy_failure
        expect(canary.song.map { |x| x[:data] }).not_to include(:after_destroy_success)
      end

      it 'gets called before after_change_failure' do
        instance.destroy(params: params, id: 1, canary: canary)
        expect(canary.song[2][:data]).to eq :after_destroy_failure
        expect(canary.song[3][:data]).to eq :after_change_failure
      end
    end

    describe 'self#after_change_failure' do
      before do
        allow(SnFoil).to receive(:adapter).and_return(FakeFailureORMAdapter)
      end

      it 'gets called after a failed save' do
        instance.destroy(params: params, id: 1, canary: canary)
        expect(canary.song[3][:data]).to eq :after_change_failure
        expect(canary.song.map { |x| x[:data] }).not_to include(:after_change_success)
      end
    end

    describe 'self#after_destroy' do
      before do
        allow(SnFoil).to receive(:adapter).and_return(FakeFailureORMAdapter)
      end

      it 'gets called regardless of save success' do
        instance.destroy(params: params, id: 1, canary: canary)
        expect(canary.song[4][:data]).to eq :after_destroy
      end

      it 'gets called before after_change' do
        instance.destroy(params: params, id: 1, canary: canary)
        expect(canary.song[4][:data]).to eq :after_destroy
        expect(canary.song[5][:data]).to eq :after_change
      end
    end

    describe 'self#after_change' do
      before do
        allow(SnFoil).to receive(:adapter).and_return(FakeFailureORMAdapter)
      end

      it 'gets called regardless of save success' do
        instance.destroy(params: params, id: 1, canary: canary)
        expect(canary.song[5][:data]).to eq :after_change
      end
    end

    describe 'with options[:if]' do
      context 'when the provided lamba returns true' do
        before do
          including_class.before_change(if: ->(_) { true }) do |opts|
            opts[:canary].sing(:conditional)
            opts
          end
        end

        it 'runs the lambda' do
          instance.destroy(params: params, id: 1, canary: canary)
          expect(canary.song.map { |x| x[:data] }).to include :conditional
        end
      end

      context 'when the provided lamba returns false' do
        before do
          including_class.before_change(if: ->(_) { false }) do |opts|
            opts[:canary].sing(:conditional)
            opts
          end
        end

        it 'doesn\'t run the lambda' do
          instance.destroy(params: params, id: 1, canary: canary)
          expect(canary.song.map { |x| x[:data] }).not_to include :conditional
        end
      end
    end

    describe 'with options[:unless]' do
      context 'when the provided lamba returns true' do
        before do
          including_class.before_change(unless: ->(_) { true }) do |opts|
            opts[:canary].sing(:conditional)
            opts
          end
        end

        it 'doesn\'t run the lambda' do
          instance.destroy(params: params, id: 1, canary: canary)
          expect(canary.song.map { |x| x[:data] }).not_to include :conditional
        end
      end

      context 'when the provided lamba returns false' do
        before do
          including_class.before_change(unless: ->(_) { false }) do |opts|
            opts[:canary].sing(:conditional)
            opts
          end
        end

        it 'runs the lambda' do
          instance.destroy(params: params, id: 1, canary: canary)
          expect(canary.song.map { |x| x[:data] }).to include :conditional
        end
      end
    end
  end
end

class DestroyContextClass
  include SnFoil::Contexts::DestroyContextConcern
end
