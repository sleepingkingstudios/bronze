# spec/bronze/collections/criteria/match_criterion_spec.rb

require 'bronze/collections/criteria/match_criterion'

RSpec.describe Bronze::Collections::Criteria::MatchCriterion do
  let(:selector) { { :id => '0' } }
  let(:instance) { described_class.new selector }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#selector' do
    include_examples 'should have reader', :selector, ->() { be == selector }
  end # describe

  describe '#type' do
    include_examples 'should have reader', :type, :filter
  end # describe
end # describe
