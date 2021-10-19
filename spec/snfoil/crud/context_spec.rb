# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SnFoil::CRUD::Context do
  let(:including_class) { Class.new ContextClass }

  it 'includes BuildContext' do
    expect(including_class.ancestors).to include(SnFoil::Contexts::BuildContext)
  end

  it 'includes IndexContext' do
    expect(including_class.ancestors).to include(SnFoil::Contexts::IndexContext)
  end

  it 'includes ShowContext' do
    expect(including_class.ancestors).to include(SnFoil::Contexts::ShowContext)
  end

  it 'includes CreateContext' do
    expect(including_class.ancestors).to include(SnFoil::Contexts::CreateContext)
  end

  it 'includes UpdateContext' do
    expect(including_class.ancestors).to include(SnFoil::Contexts::UpdateContext)
  end

  it 'includes DestroyContext' do
    expect(including_class.ancestors).to include(SnFoil::Contexts::DestroyContext)
  end
end

class ContextClass
  include SnFoil::CRUD::Context
end
