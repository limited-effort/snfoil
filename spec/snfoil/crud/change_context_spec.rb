# frozen_string_literal: true

require 'spec_helper'
require 'dry-struct'

RSpec.describe SnFoil::CRUD::ChangeContext do
  let(:including_class) { ChangeContextClass.clone }

  let(:permitted_params) { %i[first_name last_name] }

  before do
    including_class.model(double)
  end

  describe '#self.params' do
    before { including_class.params(*permitted_params) }

    it 'sets the internal params' do
      expect(including_class.i_params).to eq(permitted_params)
    end
  end

  describe '#setup_change' do
    let(:instance) { including_class.new }
    let(:params) do
      { first_name: 'test', middle_name: 'test', last_name: 'test' }
    end

    context 'when params are set on the context' do
      before { including_class.params(*permitted_params) }

      it 'permits the provided params' do
        expect(instance.run_interval(:setup_change, params: params)[:params].keys).to include(*permitted_params)
        expect(instance.run_interval(:setup_change, params: params)[:params].keys).not_to include(:middle_name)
      end
    end

    context 'when there are no params set on the context' do
      it 'does not change the params' do
        expect(instance.run_interval(:setup_change, params: params)[:params].keys).to include(*permitted_params)
        expect(instance.run_interval(:setup_change, params: params)[:params].keys).to include(:middle_name)
      end
    end
  end
end

class ChangeContextClass
  include SnFoil::CRUD::ChangeContext
end
