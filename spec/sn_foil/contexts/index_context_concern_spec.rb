# frozen_string_literal: true

require 'spec_helper'
require 'sn_foil/contexts/index_context_concern'
require 'sn_foil/searcher'
require_relative '../shared_contexts'

RSpec.describe SnFoil::Contexts::IndexContextConcern do
  include_context 'with fake policy'
  let(:including_class) { Class.new IndexContextClass }

  let(:instance) { including_class.new(user) }
  let(:searcher) { TestSeacher }
  let(:searcher_double) { class_double(searcher) }
  let(:searcher_instance_double) { instance_double(searcher) }
  let(:params) { {} }

  before do
    including_class.model_class(model_double)
    including_class.policy_class(FakePolicy)
    allow(searcher_double).to receive(:new).and_return(searcher_instance_double)
  end

  describe '#self.searcher_class' do
    before { including_class.searcher_class(searcher_double) }

    it 'sets the internal searcher class' do
      expect(including_class.i_searcher_class).to eq(searcher_double)
    end
  end

  describe 'self#index' do
    let(:instance) { instance_double(including_class) }

    before do
      allow(including_class).to receive(:index).and_call_original
      allow(including_class).to receive(:new).and_return(instance)
      allow(instance).to receive(:index)
    end

    it 'instantiates a new instance of the class and calls index' do
      including_class.index(params: params)
      expect(including_class).to have_received(:new).once
      expect(instance).to have_received(:index).once
    end
  end

  describe '#searcher_class' do
    before { including_class.searcher_class(searcher_double) }

    it 'returns the class internal searcher class' do
      expect(including_class.new.searcher_class).to eq(searcher_double)
    end
  end

  describe '#index' do
    before do
      including_class.searcher_class(searcher_double)
      allow(instance).to receive(:setup_index).and_call_original
    end

    it 'calls #setup_index' do
      instance.index(params: params)
      expect(instance).to have_received(:setup_index)
    end

    context 'with options[:searcher]' do
      let(:other_searcher_double) { class_double(searcher) }
      let(:other_searcher_instance_double) { instance_double(searcher) }

      before do
        allow(other_searcher_double).to receive(:new).and_return(other_searcher_instance_double)
      end

      it 'uses the options searcher class' do
        expect(instance.index(params: params, searcher: other_searcher_double)).to eq(other_searcher_instance_double)
        expect(other_searcher_double).to have_received(:new).once
      end

      it 'provides scope to the searcher' do
        instance.index(params: params, searcher: other_searcher_double)
        expect(model_double).to have_received(:all)
        expect(other_searcher_double).to have_received(:new).with(hash_including(params: params, scope: relation_double))
      end
    end

    context 'without options[:searcher]' do
      it 'uses the context\'s searcher class' do
        expect(instance.index(params: params)).to eq(searcher_instance_double)
        expect(searcher_double).to have_received(:new).once
      end

      it 'provides scope to the searcher' do
        instance.index(params: params)
        expect(model_double).to have_received(:all)
        expect(searcher_double).to have_received(:new).with(hash_including(params: params, scope: relation_double))
      end
    end
  end
end

class TestSeacher
  include SnFoil::Searcher
end

class IndexContextClass
  include SnFoil::Contexts::IndexContextConcern
end
