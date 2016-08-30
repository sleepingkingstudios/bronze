# spec/bronze/collections/criteria/criterion_spec.rb

require 'bronze/collections/criteria/criterion'

RSpec.describe Bronze::Collections::Criteria::Criterion do
  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '#call' do
    it { expect(instance).to respond_to(:call).with_unlimited_arguments }

    it 'should raise an error' do
      expect { instance.call double('object') }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement #call"
    end # it
  end # describe

  describe '#type' do
    include_examples 'should have reader', :type
  end # describe
end # describe
