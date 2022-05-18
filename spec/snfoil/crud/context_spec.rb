# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SnFoil::CRUD::Context do
  let(:including_class) { Class.new ContextClass }

  it 'includes BuildContext' do
    expect(including_class.ancestors).to include(SnFoil::CRUD::BuildContext)
  end

  it 'includes IndexContext' do
    expect(including_class.ancestors).to include(SnFoil::CRUD::IndexContext)
  end

  it 'includes ShowContext' do
    expect(including_class.ancestors).to include(SnFoil::CRUD::ShowContext)
  end

  it 'includes CreateContext' do
    expect(including_class.ancestors).to include(SnFoil::CRUD::CreateContext)
  end

  it 'includes UpdateContext' do
    expect(including_class.ancestors).to include(SnFoil::CRUD::UpdateContext)
  end

  it 'includes DestroyContext' do
    expect(including_class.ancestors).to include(SnFoil::CRUD::DestroyContext)
  end
end

class ContextClass
  include SnFoil::CRUD::Context
end
