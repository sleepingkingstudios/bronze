# spec/bronze/collections/reference/collection_spec.rb

require 'bronze/collections/collection_examples'
require 'bronze/collections/reference/collection'
require 'bronze/transforms/identity_transform'

RSpec.describe Bronze::Collections::Reference::Collection do
  include Spec::Collections::CollectionExamples

  let(:data)        { [] }
  let(:instance)    { described_class.new data }
  let(:query_class) { Patina::Collections::Simple::Query }

  def find_item id
    items = instance.all.to_a

    if items.empty?
      nil
    elsif items.first.is_a?(Hash)
      items.find { |hsh| hsh[:id] == id }
    else
      items.find { |obj| obj.id == id }
    end # if-elsif-else
  end # method find_item

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1..2).arguments }
  end # describe

  include_examples 'should implement the Collection interface'

  include_examples 'should implement the Collection methods'

  describe '#transform' do
    context 'when the instance is initialized with a transform' do
      let(:transform) { Bronze::Transforms::IdentityTransform.new }
      let(:instance)  { described_class.new data, transform }

      it { expect(instance.transform).to be transform }
    end # context
  end # describe
end # describe
