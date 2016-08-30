# spec/bronze/collections/criteria/limit_criterion_spec.rb

require 'bronze/collections/criteria/limit_criterion'

RSpec.describe Bronze::Collections::Criteria::LimitCriterion do
  let(:count)    { 3 }
  let(:instance) { described_class.new count }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#count' do
    include_examples 'should have reader', :count, ->() { be == count }
  end # describe

  describe '#type' do
    include_examples 'should have reader', :type, :limit
  end # describe
end # describe
