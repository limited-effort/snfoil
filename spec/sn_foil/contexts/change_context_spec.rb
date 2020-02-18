# frozen_string_literal: true

require 'spec_helper'
require 'sn_foil/contexts/change_context'
require 'dry-struct'

RSpec.describe SnFoil::Contexts::ChangeContext do
  let(:including_class) { Class.new ChangeContextClass }

  let(:whitelisted_params) { %i[first_name last_name] }

  before do
    including_class.model(OpenStruct)
  end

  describe '#self.params' do
    before { including_class.params(*whitelisted_params) }

    it 'sets the internal params' do
      expect(including_class.i_params).to eq(whitelisted_params)
    end
  end

  describe '#param_names' do
    context 'with context params set' do
      before { including_class.params(*whitelisted_params) }

      it 'returns the internal params' do
        expect(including_class.new.param_names).to eq(whitelisted_params)
      end
    end
  end

  describe '#setup_change' do
    let(:instance) { including_class.new }
    let(:params) do
      { first_name: 'test', middle_name: 'test', last_name: 'test' }
    end

    context 'when params are set on the context' do
      before { including_class.params(*whitelisted_params) }

      it 'whitelists the provided params' do
        expect(instance.setup_change(params: params)[:params].keys).to include(*whitelisted_params)
        expect(instance.setup_change(params: params)[:params].keys).not_to include(:middle_name)
      end
    end

    context 'when there are no params set on the context' do
      it 'does not change the params' do
        expect(instance.setup_change(params: params)[:params].keys).to include(*whitelisted_params)
        expect(instance.setup_change(params: params)[:params].keys).to include(:middle_name)
      end
    end
  end
end

class ChangeContextClass
  include SnFoil::Contexts::ChangeContext
end
