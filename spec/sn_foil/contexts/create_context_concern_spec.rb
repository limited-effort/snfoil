# frozen_string_literal: true

require 'spec_helper'
require 'sn_foil/contexts/create_context_concern'
require_relative '../shared_contexts'
require 'ostruct'

RSpec.describe SnFoil::Contexts::CreateContextConcern do
  include_context 'with fake policy'
  let(:including_class) { Class.new CreateContextClass }

  let(:instance) { including_class.new(user) }
  let(:user) { double }
  let(:params) { {} }

  before do
    including_class.model_class(model_double)
    including_class.policy_class(policy)
  end

  describe 'self#create' do
    let(:instance) { instance_double(including_class) }

    before do
      allow(including_class).to receive(:create).and_call_original
      allow(including_class).to receive(:new).and_return(instance)
      allow(instance).to receive(:create)
    end

    it 'instantiates a new instance of the class and calls create' do
      including_class.create(params: params)
      expect(including_class).to have_received(:new).once
      expect(instance).to have_received(:create).once
    end
  end

  describe '#setup_create_object' do
    context 'with options[:object]' do
      it 'directly returns any object provided in the options' do
        object = double
        expect(instance.setup_create_object(params: {}, object: object)).to eq object
      end
    end

    context 'with options[:model_class]' do
      let(:other_model_double) { Person }
      let(:other_model_instance_double) { other_model_double.new(first_name: 'Other', last_name: 'Human') }

      before do
        allow(other_model_double).to receive(:new).and_return(other_model_instance_double)
      end

      it 'instantiates an object using the options model class' do
        expect(instance.setup_create_object(params: {}, model_class: other_model_double)).to eq other_model_instance_double
        expect(other_model_double).to have_received(:new).twice # Once for creation and once for attr assignment
      end
    end

    context 'without options[:model_class]' do
      it 'instantiates an object using the contexts model class' do
        expect(instance.setup_create_object(params: {})).to eq(model_instance_double)
        expect(model_double).to have_received(:new)
      end
    end
  end

  describe '#create' do
    it 'sets an action in the options' do
      allow(instance).to receive(:setup_create).and_call_original
      instance.create(params: params)
      expect(instance).to have_received(:setup_create).with(hash_including(action: :create))
    end

    it 'authorizes the object' do
      instance.create(params: params)
      expect(policy).to have_received(:new).with(user, FakeSuccessORMAdapter)
      expect(policy_double).to have_received(:create?).once
    end

    it 'calls #setup_create' do
      allow(instance).to receive(:setup_create).and_call_original
      instance.create(params: params)
      expect(instance).to have_received(:setup_create).once
    end

    it 'calls #before_create' do
      allow(instance).to receive(:before_create).and_call_original
      instance.create(params: params)
      expect(instance).to have_received(:before_create).once
    end

    context 'when the save is successful' do
      it 'calls #after_create_success' do
        allow(instance).to receive(:after_create_success).and_call_original
        instance.create(params: params)
        expect(instance).to have_received(:after_create_success).once
      end

      it 'calls #after_change_success' do
        allow(instance).to receive(:after_change_success).and_call_original
        instance.create(params: params)
        expect(instance).to have_received(:after_change_success).once
      end
    end

    context 'when the save isn\'t successful' do
      before do
        allow(SnFoil).to receive(:adapter).and_return(FakeFailureORMAdapter)
      end

      it 'calls #after_create_failure' do
        allow(instance).to receive(:after_create_failure).and_call_original
        instance.create(params: params)
        expect(instance).to have_received(:after_create_failure).once
      end

      it 'calls #after_change_failure' do
        allow(instance).to receive(:after_change_failure).and_call_original
        instance.create(params: params)
        expect(instance).to have_received(:after_change_failure).once
      end
    end
  end

  context 'when hooks are provided' do
    let(:canary) { double }

    before do
      allow(canary).to receive(:ping).with(instance_of(Symbol))

      # Setup Action Hooks
      including_class.before_create do |obj, opts|
        opts[:canary].ping(:before_create)
        obj
      end
      including_class.before_change do |obj, opts|
        opts[:canary].ping(:before_change)
        obj
      end
      including_class.after_create_success do |obj, opts|
        opts[:canary].ping(:after_create_success)
        obj
      end
      including_class.after_change_success do |obj, opts|
        opts[:canary].ping(:after_change_success)
        obj
      end
      including_class.after_create_failure do |obj, opts|
        opts[:canary].ping(:after_create_failure)
        obj
      end
      including_class.after_change_failure do |obj, opts|
        opts[:canary].ping(:after_change_failure)
        obj
      end
      including_class.after_create do |obj, opts|
        opts[:canary].ping(:after_create)
        obj
      end
      including_class.after_change do |obj, opts|
        opts[:canary].ping(:after_change)
        obj
      end
    end

    describe 'self#before_create' do
      before do
        allow(SnFoil).to receive(:adapter).and_return(FakeErrorORMAdapter)
      end

      it 'gets called before any save' do
        expect do
          instance.create(params: params, canary: canary)
        end.to raise_error(StandardError)
        expect(canary).to have_received(:ping).exactly(2).times
        expect(canary).to have_received(:ping).with(:before_create).once
      end
    end

    describe 'self#before_change' do
      before do
        allow(SnFoil).to receive(:adapter).and_return(FakeErrorORMAdapter)
      end

      it 'gets called before any save' do
        expect do
          instance.create(params: params, canary: canary)
        end.to raise_error(StandardError)
        expect(canary).to have_received(:ping).exactly(2).times
        expect(canary).to have_received(:ping).with(:before_change).once
      end
    end

    describe 'self#after_create_success' do
      it 'gets called after a successful save' do
        instance.create(params: params, canary: canary)
        expect(canary).to have_received(:ping).exactly(6).times
        expect(canary).to have_received(:ping).with(:after_create_success).once
        expect(canary).not_to have_received(:ping).with(:after_create_failure)
      end
    end

    describe 'self#after_change_success' do
      it 'gets called after a successful save' do
        instance.create(params: params, canary: canary)
        expect(canary).to have_received(:ping).exactly(6).times
        expect(canary).to have_received(:ping).with(:after_change_success).once
        expect(canary).not_to have_received(:ping).with(:after_change_failure)
      end
    end

    describe 'self#after_create_failure' do
      before do
        allow(SnFoil).to receive(:adapter).and_return(FakeFailureORMAdapter)
      end

      it 'gets called after a failed save' do
        instance.create(params: params, canary: canary)
        expect(canary).to have_received(:ping).exactly(6).times
        expect(canary).to have_received(:ping).with(:after_create_failure).once
        expect(canary).not_to have_received(:ping).with(:after_create_success)
      end
    end

    describe 'self#after_change_failure' do
      before do
        allow(SnFoil).to receive(:adapter).and_return(FakeFailureORMAdapter)
      end

      it 'gets called after a failed save' do
        instance.create(params: params, canary: canary)
        expect(canary).to have_received(:ping).exactly(6).times
        expect(canary).to have_received(:ping).with(:after_change_failure).once
        expect(canary).not_to have_received(:ping).with(:after_change_success)
      end
    end

    describe 'self#after_create' do
      before do
        allow(SnFoil).to receive(:adapter).and_return(FakeFailureORMAdapter)
      end

      it 'gets called regardless of save success' do
        instance.create(params: params, canary: canary)
        expect(canary).to have_received(:ping).exactly(6).times
        expect(canary).to have_received(:ping).with(:after_create).once
      end
    end

    describe 'self#after_change' do
      before do
        allow(SnFoil).to receive(:adapter).and_return(FakeFailureORMAdapter)
      end

      it 'gets called regardless of save success' do
        instance.create(params: params, canary: canary)
        expect(canary).to have_received(:ping).exactly(6).times
        expect(canary).to have_received(:ping).with(:after_change).once
      end
    end

    describe 'with options[:if]' do
      context 'when the provided lamba returns true' do
        before do
          including_class.before_change(if: ->(_, _) { true }) do |obj, opts|
            opts[:canary].ping(:conditional)
            obj
          end
        end

        it 'runs the lambda' do
          instance.create(params: params, canary: canary)
          expect(canary).to have_received(:ping).exactly(7).times
          expect(canary).to have_received(:ping).with(:conditional).once
        end
      end

      context 'when the provided lamba returns false' do
        before do
          including_class.before_change(if: ->(_, _) { false }) do |obj, opts|
            opts[:canary].ping(:conditional)
            obj
          end
        end

        it 'doesn\'t run the lambda' do
          instance.create(params: params, canary: canary)
          expect(canary).to have_received(:ping).exactly(6).times
          expect(canary).not_to have_received(:ping).with(:conditional)
        end
      end
    end

    describe 'with options[:unless]' do
      context 'when the provided lamba returns true' do
        before do
          including_class.before_change(unless: ->(_, _) { true }) do |obj, opts|
            opts[:canary].ping(:conditional)
            obj
          end
        end

        it 'doesn\'t run the lambda' do
          instance.create(params: params, canary: canary)
          expect(canary).to have_received(:ping).exactly(6).times
          expect(canary).not_to have_received(:ping).with(:conditional)
        end
      end

      context 'when the provided lamba returns false' do
        before do
          including_class.before_change(unless: ->(_, _) { false }) do |obj, opts|
            opts[:canary].ping(:conditional)
            obj
          end
        end

        it 'runs the lambda' do
          instance.create(params: params, canary: canary)
          expect(canary).to have_received(:ping).exactly(7).times
          expect(canary).to have_received(:ping).with(:conditional).once
        end
      end
    end
  end
end

class CreateContextClass
  include SnFoil::Contexts::CreateContextConcern
end
