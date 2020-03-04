# frozen_string_literal: true

require 'spec_helper'
require 'sn_foil/contexts/update_context'
require_relative '../shared_contexts'

RSpec.describe SnFoil::Contexts::UpdateContext do
  include_context 'with fake policy'
  let(:including_class) { Class.new UpdateContextClass }

  let(:instance) { including_class.new(user) }
  let(:params) { { first_name: 'John', last_name: 'Doe' } }

  before do
    including_class.model(model_double)
    including_class.policy(policy)
  end

  describe 'self#update' do
    let(:instance) { instance_double(including_class) }

    before do
      allow(including_class).to receive(:update).and_call_original
      allow(including_class).to receive(:new).and_return(instance)
      allow(instance).to receive(:update)
    end

    it 'instantiates a new instance of the class and calls update' do
      including_class.update(params: params, id: 1)
      expect(including_class).to have_received(:new).once
      expect(instance).to have_received(:update).once
    end
  end

  describe '#setup_update_object' do
    context 'without options[:id] or options[:object]' do
      it 'raises an error' do
        expect do
          instance.setup_update_object(params: {})
        end.to raise_error ArgumentError
      end
    end

    context 'with options[:object]' do
      let(:object) { Person.new(first_name: nil, last_name: nil) }

      it 'operates on any object provided in the options' do
        expect(instance.setup_update_object(params: {}, object: object)[:object]).to eq object
      end

      it 'authorizes any (wrapped) object provided in the options' do
        instance.setup_update_object(params: {}, object: object)
        expect(policy).to have_received(:new).with(user, FakeSuccessORMAdapter)
        expect(policy_double).to have_received(:update?).once
      end

      it 'updates the attributes of any object provided in the options' do
        allow(object).to receive(:attributes).and_call_original
        instance.setup_update_object(params: {}, object: object)
        expect(object).to have_received(:attributes).once
      end
    end

    context 'with options[:id]' do
      it 'lookups the object in the scope' do
        expect(instance.setup_update_object(params: {}, id: 1)[:object]).to eq model_instance_double
        expect(relation_double).to have_received(:find).once
      end

      it 'authorizes any object provided in the options' do
        instance.setup_update_object(params: {}, id: 1)
        expect(policy).to have_received(:new).with(user, FakeSuccessORMAdapter)
        expect(policy_double).to have_received(:update?).once
      end

      it 'updates the attributes of any object provided in the options' do
        allow(model_instance_double).to receive(:attributes).and_call_original
        instance.setup_update_object(params: {}, id: 1)
        expect(model_instance_double).to have_received(:attributes).once
      end
    end
  end

  describe '#update' do
    it 'sets an action in the options' do
      allow(instance).to receive(:setup_update).and_call_original
      instance.update(params: params, id: 1)
      expect(instance).to have_received(:setup_update).with(hash_including(action: :update))
    end

    it 'authorizes the object before and after the changes' do
      instance.update(params: params, id: 1)
      expect(policy).to have_received(:new).with(user, FakeSuccessORMAdapter).twice
      expect(policy_double).to have_received(:update?).twice
    end

    it 'calls #setup' do
      allow(instance).to receive(:setup).and_call_original
      instance.update(params: params, id: 1)
      expect(instance).to have_received(:setup).once
    end

    it 'calls #setup_update' do
      allow(instance).to receive(:setup_update).and_call_original
      instance.update(params: params, id: 1)
      expect(instance).to have_received(:setup_update).once
    end

    it 'calls #before_update' do
      allow(instance).to receive(:before_update).and_call_original
      instance.update(params: params, id: 1)
      expect(instance).to have_received(:before_update).once
    end

    context 'when the save is successful' do
      it 'calls #after_update_success' do
        allow(instance).to receive(:after_update_success).and_call_original
        instance.update(params: params, id: 1)
        expect(instance).to have_received(:after_update_success).once
      end

      it 'calls #after_change_success' do
        allow(instance).to receive(:after_change_success).and_call_original
        instance.update(params: params, id: 1)
        expect(instance).to have_received(:after_change_success).once
      end
    end

    context 'when the save isn\'t successful' do
      before do
        allow(SnFoil).to receive(:adapter).and_return(FakeFailureORMAdapter)
      end

      it 'calls #after_update_failure' do
        allow(instance).to receive(:after_update_failure).and_call_original
        instance.update(params: params, id: 1)
        expect(instance).to have_received(:after_update_failure).once
      end

      it 'calls #after_change_failure' do
        allow(instance).to receive(:after_change_failure).and_call_original
        instance.update(params: params, id: 1)
        expect(instance).to have_received(:after_change_failure).once
      end
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
      including_class.setup_update do |opts|
        opts[:canary].sing(:setup_update)
        opts
      end
      including_class.before_update do |opts|
        opts[:canary].sing(:before_update)
        opts
      end
      including_class.before_change do |opts|
        opts[:canary].sing(:before_change)
        opts
      end
      including_class.after_update_success do |opts|
        opts[:canary].sing(:after_update_success)
        opts
      end
      including_class.after_change_success do |opts|
        opts[:canary].sing(:after_change_success)
        opts
      end
      including_class.after_update_failure do |opts|
        opts[:canary].sing(:after_update_failure)
        opts
      end
      including_class.after_change_failure do |opts|
        opts[:canary].sing(:after_change_failure)
        opts
      end
      including_class.after_update do |opts|
        opts[:canary].sing(:after_update)
        opts
      end
      including_class.after_change do |opts|
        opts[:canary].sing(:after_change)
        opts
      end
    end

    describe 'self#setup_update' do
      it 'gets called first' do
        instance.update(params: params, id: 1, canary: canary)
        expect(canary.song[0][:data]).to eq :setup_update
      end
    end

    describe 'self#setup' do
      it 'gets called after setup_update' do
        instance.update(params: params, id: 1, canary: canary)
        expect(canary.song[0][:data]).to eq :setup_update
        expect(canary.song[1][:data]).to eq :setup
      end
    end

    describe 'self#before_update' do
      it 'gets called before any save' do
        instance.update(params: params, id: 1, canary: canary)
        expect(canary.song[2][:data]).to eq :before_update
        expect(canary.song[4][:data]).to eq :after_update_success
      end

      it 'gets called before :before_change' do
        instance.update(params: params, id: 1, canary: canary)
        expect(canary.song[2][:data]).to eq :before_update
        expect(canary.song[3][:data]).to eq :before_change
      end
    end

    describe 'self#before_change' do
      it 'gets called before any save' do
        instance.update(params: params, id: 1, canary: canary)
        expect(canary.song[3][:data]).to eq :before_change
        expect(canary.song[4][:data]).to eq :after_update_success
      end
    end

    describe 'self#after_update_success' do
      it 'gets called after a successful save' do
        instance.update(params: params, id: 1, canary: canary)
        expect(canary.song[4][:data]).to eq :after_update_success
        expect(canary.song.map { |x| x[:data] }).not_to include(:after_change_failure)
      end

      it 'gets called before after_update_success' do
        instance.update(params: params, id: 1, canary: canary)
        expect(canary.song[4][:data]).to eq :after_update_success
        expect(canary.song[5][:data]).to eq :after_change_success
      end
    end

    describe 'self#after_change_success' do
      it 'gets called after a successful save' do
        instance.update(params: params, id: 1, canary: canary)
        expect(canary.song[5][:data]).to eq :after_change_success
        expect(canary.song.map { |x| x[:data] }).not_to include(:after_change_failure)
      end
    end

    describe 'self#after_update_failure' do
      before do
        allow(SnFoil).to receive(:adapter).and_return(FakeFailureORMAdapter)
      end

      it 'gets called after a failed save' do
        instance.update(params: params, id: 1, canary: canary)
        expect(canary.song[4][:data]).to eq :after_update_failure
        expect(canary.song.map { |x| x[:data] }).not_to include(:after_update_success)
      end

      it 'gets called before after_change_failure' do
        instance.update(params: params, id: 1, canary: canary)
        expect(canary.song[4][:data]).to eq :after_update_failure
        expect(canary.song[5][:data]).to eq :after_change_failure
      end
    end

    describe 'self#after_change_failure' do
      before do
        allow(SnFoil).to receive(:adapter).and_return(FakeFailureORMAdapter)
      end

      it 'gets called after a failed save' do
        instance.update(params: params, id: 1, canary: canary)
        expect(canary.song[5][:data]).to eq :after_change_failure
        expect(canary.song.map { |x| x[:data] }).not_to include(:after_change_success)
      end
    end

    describe 'self#after_update' do
      before do
        allow(SnFoil).to receive(:adapter).and_return(FakeFailureORMAdapter)
      end

      it 'gets called regardless of save success' do
        instance.update(params: params, id: 1, canary: canary)
        expect(canary.song[6][:data]).to eq :after_update
      end

      it 'gets called before after_change' do
        instance.update(params: params, id: 1, canary: canary)
        expect(canary.song[6][:data]).to eq :after_update
        expect(canary.song[7][:data]).to eq :after_change
      end
    end

    describe 'self#after_change' do
      before do
        allow(SnFoil).to receive(:adapter).and_return(FakeFailureORMAdapter)
      end

      it 'gets called regardless of save success' do
        instance.update(params: params, id: 1, canary: canary)
        expect(canary.song[7][:data]).to eq :after_change
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
          instance.update(params: params, id: 1, canary: canary)
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
          instance.update(params: params, id: 1, canary: canary)
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
          instance.update(params: params, id: 1, canary: canary)
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
          instance.update(params: params, id: 1, canary: canary)
          expect(canary.song.map { |x| x[:data] }).to include :conditional
        end
      end
    end
  end
end

class UpdateContextClass
  include SnFoil::Contexts::UpdateContext
end
