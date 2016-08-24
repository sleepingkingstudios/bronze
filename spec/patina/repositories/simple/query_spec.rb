# spec/patina/repositories/simple/query_spec.rb

require 'bronze/entities/transforms/identity_transform'
require 'bronze/repositories/query_examples'
require 'patina/repositories/simple/query'

RSpec.describe Patina::Repositories::Simple::Query do
  include Spec::Repositories::QueryExamples

  let(:transform) do
    Bronze::Entities::Transforms::IdentityTransform.new
  end # let
  let(:data)     { {} }
  let(:instance) { described_class.new(data, transform) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(2).arguments }
  end # describe

  include_examples 'should implement the Query interface'

  include_examples 'should implement the Query methods'

  describe '#transform' do
    it { expect(instance.transform).to be == transform }
  end # describe
end # describe
