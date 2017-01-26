# spec/patina/collections/mongo/criteria/match_criterion_spec.rb

require 'patina/collections/mongo/criteria/match_criterion'

RSpec.describe Patina::Collections::Mongo::Criteria::MatchCriterion do
  let(:selector) { { :id => '0' } }
  let(:instance) { described_class.new selector }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#call' do
    it { expect(instance).to respond_to(:call).with(1).argument }

    it { expect(instance.call([{}, {}])).to be == [selector, {}] }

    describe 'with existing filters' do
      let(:filters)  { { :title => 'The Silmarillion' } }
      let(:expected) { filters.merge selector }

      it { expect(instance.call([filters, {}])).to be == [expected, {}] }
    end # describe

    describe 'with existing options' do
      let(:options) { { :limit => 5 } }

      it { expect(instance.call([{}, options])).to be == [selector, options] }
    end # describe
  end # describe

  describe '#selector' do
    include_examples 'should have reader', :selector, ->() { be == selector }
  end # describe

  describe '#type' do
    include_examples 'should have reader', :type, :filter
  end # describe
end # describe
