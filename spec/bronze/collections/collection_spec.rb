# spec/bronze/collections/collection_spec.rb

require 'bronze/collections/collection'
require 'bronze/collections/collection_examples'
require 'bronze/transforms/identity_transform'

RSpec.describe Bronze::Collections::Collection do
  include Spec::Collections::CollectionExamples

  let(:described_class) { Class.new.send :include, super() }
  let(:instance)        { described_class.new }

  include_examples 'should implement the Collection interface'

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end # describe

  describe '#transform' do
    context 'when the instance is initialized with a transform' do
      let(:transform) { Bronze::Transforms::IdentityTransform.new }
      let(:instance)  { described_class.new transform }

      it { expect(instance.transform).to be transform }
    end # context
  end # describe
end # describe
