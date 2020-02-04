# frozen_string_literal: true

require 'spec_helper'
require 'sn_foil/context'

RSpec.describe SnFoil::Context do
  let(:including_class) { Class.new ContextClass }

  it 'includes BuildContextConcern' do
    expect(including_class.ancestors).to include(SnFoil::Contexts::BuildContextConcern)
  end

  it 'includes IndexContextConcern' do
    expect(including_class.ancestors).to include(SnFoil::Contexts::IndexContextConcern)
  end

  it 'includes ShowContextConcern' do
    expect(including_class.ancestors).to include(SnFoil::Contexts::ShowContextConcern)
  end

  it 'includes CreateContextConcern' do
    expect(including_class.ancestors).to include(SnFoil::Contexts::CreateContextConcern)
  end

  it 'includes UpdateContextConcern' do
    expect(including_class.ancestors).to include(SnFoil::Contexts::UpdateContextConcern)
  end

  it 'includes DestroyContextConcern' do
    expect(including_class.ancestors).to include(SnFoil::Contexts::DestroyContextConcern)
  end
end

class ContextClass
  include SnFoil::Context
end
