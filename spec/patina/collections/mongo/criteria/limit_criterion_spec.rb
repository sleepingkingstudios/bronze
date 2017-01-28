# spec/patina/collections/mongo/criteria/limit_criterion_spec.rb

require 'patina/collections/mongo/criteria/limit_criterion'

RSpec.describe Patina::Collections::Mongo::Criteria::LimitCriterion do
  let(:count)    { 5 }
  let(:instance) { described_class.new count }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#call' do
    it { expect(instance).to respond_to(:call).with(1).argument }

    it { expect(instance.call([{}, {}])).to be == [{}, { :limit => count }] }

    describe 'with existing filters' do
      let(:filters)  { { :title => 'The Silmarillion' } }
      let(:expected) { { :limit => count } }

      it { expect(instance.call([filters, {}])).to be == [filters, expected] }
    end # describe

    describe 'with existing options' do
      let(:options)  { { :skip => 5 } }
      let(:expected) { options.merge :limit => count }

      it { expect(instance.call([{}, options])).to be == [{}, expected] }
    end # describe

    describe 'with an existing limit option' do
      let(:options) { { :limit => 5 } }

      context 'when the count is less than the existing limit' do
        let(:count)    { 3 }
        let(:expected) { options.merge :limit => count }

        it { expect(instance.call([{}, options])).to be == [{}, expected] }
      end # context

      context 'when the count is greater than the existing limit' do
        let(:count)    { 7 }
        let(:expected) { options }

        it { expect(instance.call([{}, options])).to be == [{}, expected] }
      end # context
    end # describe
  end # describe

  describe '#count' do
    include_examples 'should have reader', :count, ->() { be == count }
  end # describe

  describe '#type' do
    include_examples 'should have reader', :type, :limit
  end # describe
end # describe
