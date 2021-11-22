# frozen_string_literal: true

require 'spec_helper'
require 'snfoil/searcher'
require_relative '../shared_contexts'

RSpec.describe SnFoil::CRUD::IndexContext do
  include_context 'with fake policy'
  let(:including_class) { IndexContextClass.clone }

  let(:instance) { including_class.new(entity: entity) }
  let(:searcher) { TestSeacher }
  let(:searcher_double) { class_double(searcher) }
  let(:searcher_instance_double) { instance_double(searcher) }
  let(:results) { double }
  let(:params) { {} }
  let(:canary) { Canary.new }

  before do
    including_class.model(model_double)
    including_class.policy(FakePolicy)
    allow(searcher_double).to receive(:new).and_return(searcher_instance_double)
    allow(searcher_instance_double).to receive(:search).with(anything).and_return(results)
  end

  describe '#self.searcher' do
    before { including_class.searcher(searcher_double) }

    it 'sets the internal searcher class' do
      expect(including_class.i_searcher).to eq(searcher_double)
    end
  end

  describe '#index' do
    before do
      including_class.searcher(searcher_double)
    end

    context 'with options[:searcher]' do
      let(:other_searcher_double) { class_double(searcher) }
      let(:other_searcher_instance_double) { instance_double(searcher) }
      let(:other_results) { double }

      before do
        allow(other_searcher_double).to receive(:new).and_return(other_searcher_instance_double)
        allow(other_searcher_instance_double).to receive(:search).and_return(other_results)
      end

      it 'uses the options searcher class' do
        expect(instance.index(params: params, searcher: other_searcher_double)[:object]).to eq(other_results)
        expect(other_searcher_double).to have_received(:new).once
      end

      it 'provides scope to the searcher' do
        instance.index(params: params, searcher: other_searcher_double)
        expect(model_double).to have_received(:all)
        expect(other_searcher_double).to have_received(:new).with(hash_including(scope: relation_double))
        expect(other_searcher_instance_double).to have_received(:search).with(params)
      end
    end

    context 'without options[:searcher]' do
      it 'uses the context\'s searcher class' do
        expect(instance.index(params: params)[:object]).to eq(results)
        expect(searcher_double).to have_received(:new).once
      end

      it 'provides scope to the searcher' do
        instance.index(params: params)
        expect(model_double).to have_received(:all)
        expect(searcher_double).to have_received(:new).with(hash_including(scope: relation_double))
        expect(searcher_instance_double).to have_received(:search).with(params)
      end
    end
  end

  describe 'predefined hooks' do
    before { including_class.searcher(searcher_double) }

    it 'calls setup before setup_index' do
      instance.index(params: {}, canary: canary)
      index = canary.song.index { |s| s[:data] == :setup }
      expect(canary.song[index + 1][:data]).to eq :setup_index
    end
  end
end

class TestSeacher
  include SnFoil::Searcher
end

class IndexContextClass
  include SnFoil::CRUD::IndexContext

  setup do |opts|
    opts[:canary]&.sing(:setup)
    opts
  end

  setup_index do |opts|
    opts[:canary]&.sing(:setup_index)
    opts
  end
end
