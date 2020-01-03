# frozen_string_literal: true

require 'spec_helper'
require 'sn_foil/searcher'
require 'active_support/concern'
require_relative './shared_contexts'

RSpec.describe SnFoil::Searcher do
  include_context 'with fake policy'

  subject(:searcher) { Class.new TestSearcherClass }

  let(:instance) { searcher.new }
  let(:query) { instance.results }

  before do
    searcher.model_class model_double
    allow(model_double).to receive(:all).and_return(FakeScope.new(Person, '"people".*'))
  end

  describe '#initialize' do
    let(:query) { instance.results.scope }

    context 'when a scope is provided' do
      let(:instance) { searcher.new(scope: FakeScope.new(Person, '"doctors".*')) }

      it 'sets the internal scope to the provided scope' do
        expect(query).to match(/"doctors".\*/)
      end
    end

    context 'when a scope isn\'t provided' do
      it 'sets the internal scope to the model' do
        expect(query).to match(/"people".\*/)
      end
    end
  end

  describe 'self#model_class' do
    it 'sets the internal model class' do
      expect(instance.model_class.to_s).to match(/Person/)
    end
  end

  describe 'self#filter' do
    context 'with params[:if]' do
      context 'when the provided lamba returns true' do
        before do
          searcher.filter(if: ->(_) { true }) do |scope, _|
            scope.where('"people"."client_id" = 1')
          end
        end

        it 'adds the filter to the query' do
          expect(query).to match(/"people"."client_id" = 1/)
        end
      end

      context 'when the provided lamba returns false' do
        before do
          searcher.filter(if: ->(_) { false }) do |scope, _|
            scope.where('"people"."client_id" = 2')
          end
        end

        it 'doesn\'t add the filter to the query' do
          expect(query).not_to match(/"people"."client_id" = 2/)
        end
      end
    end

    context 'with params[:unless]' do
      context 'when the provided lamba returns true' do
        before do
          searcher.filter(unless: ->(_) { true }) do |scope, _|
            scope.where('"people"."client_id" = 3')
          end
        end

        it 'doesn\'t add the filter to the query' do
          expect(query).not_to match(/"people"."client_id" = 3/)
        end
      end

      context 'when the provided lamba returns false' do
        before do
          searcher.filter(unless: ->(_) { false }) do |scope, _|
            scope.where('"people"."client_id" = 4')
          end
        end

        it 'adds the filter to the query' do
          expect(query).to match(/"people"."client_id" = 4/)
        end
      end
    end
  end

  describe '#reset_scope' do
    before do
      searcher.filter { |scope, _| scope.where('"people"."client_id" = 5') }
    end

    it 'resets the internal scope to the intialized scope' do
      expect(query).to match(/"people"."client_id" = 5/)
      expect do
        instance.reset_scope
      end.to change(instance, :scope)
    end
  end

  describe '#filtered_results' do
    before do
      def instance.filtered_results
        '"farmers".*'
      end
    end

    it 'overrides the default scope and uses the return' do
      expect(query).to match(/"farmers".\*/)
      expect(query).not_to match(/"people".\*/)
    end
  end

  describe '#results' do
    before do
      searcher.filter { |scope, _| scope.where('"people"."client_id" = 6') }
    end

    it 'returns the scope of the built query' do
      expect(query).to match(/"people"."client_id" = 6/)
    end
  end
end

module PersonExtension
  extend ActiveSupport::Concern

  class_methods do
    def where(addition)
      FakeScope.new(Person).where(addition)
    end
  end
end

class Person
  prepend PersonExtension
end

class TestSearcherClass
  include SnFoil::Searcher
end

class FakeScope
  attr_reader :model, :scope
  def initialize(model, scope = '')
    @model = model
    @scope = scope
  end

  def where(addition)
    @scope += ' ' unless @scope.empty?
    @scope += addition
  end
end
