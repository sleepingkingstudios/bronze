# spec/patina/collections/simple/query_spec.rb

require 'bronze/collections/query_examples'
require 'bronze/transforms/identity_transform'

require 'patina/collections/simple/query'

RSpec.describe Patina::Collections::Simple::Query do
  include Spec::Collections::QueryExamples

  let(:transform) do
    Bronze::Transforms::IdentityTransform.new
  end # let
  let(:raw_data) { [] }
  let(:data)     { raw_data }
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
