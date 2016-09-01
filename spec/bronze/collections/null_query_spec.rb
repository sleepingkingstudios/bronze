# spec/bronze/collections/null_query_spec.rb

require 'bronze/collections/null_query'
require 'bronze/collections/query_examples'

RSpec.describe Bronze::Collections::NullQuery do
  include Spec::Collections::QueryExamples

  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  include_examples 'should implement the Query interface'

  describe '#count' do
    it { expect(instance.count).to be 0 }
  end # describe

  describe '#exists?' do
    it { expect(instance.exists?).to be false }
  end # describe

  describe '#limit' do
    it { expect(instance.limit(0)).to be instance }
  end # describe

  describe '#matching' do
    it { expect(instance.matching({})).to be instance }
  end # describe

  describe '#pluck' do
    it { expect(instance.pluck(:id)).to be == [] }
  end # describe

  describe '#to_a' do
    it { expect(instance.to_a).to be == [] }
  end # describe

  describe '#transform' do
    it { expect(instance.transform).to be nil }
  end # describe
end # describe
