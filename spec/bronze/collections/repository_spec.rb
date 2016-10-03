# spec/bronze/collections/repository_spec.rb

require 'bronze/collections/collection_builder'
require 'bronze/collections/repository'

RSpec.describe Bronze::Collections::Repository do
  let(:described_class) do
    Class.new.tap do |klass|
      klass.send :include, super()
    end # class
  end # let
  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '#collection' do
    it { expect(instance).to respond_to(:collection).with(1..2).arguments }

    it 'should raise an error' do
      error_class = Bronze::Collections::CollectionBuilder

      expect { instance.collection :books }.
        to raise_error error_class::NotImplementedError,
          "#{error_class.name} does not implement :build_collection"
    end # it
  end # describe
end # describe
