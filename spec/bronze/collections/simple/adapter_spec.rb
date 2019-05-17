# frozen_string_literal: true

require 'bronze/collections/null_query'
require 'bronze/collections/simple/adapter'

require 'support/examples/collections/adapter_examples'

RSpec.describe Bronze::Collections::Simple::Adapter do
  include Spec::Support::Examples::Collections::AdapterExamples

  subject(:adapter) do
    data = raw_data.each.with_object({}) do |(name, collection), hsh|
      hsh[name] = collection.map { |item| tools.hash.deep_dup(item) }
    end

    described_class.new(data)
  end

  let(:query_class) { Bronze::Collections::Simple::Query }
  let(:raw_data)    { { 'books' => [] } }

  def tools
    SleepingKingStudios::Tools::Toolbelt.instance
  end

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  include_examples 'should implement the Adapter interface'

  include_examples 'should implement the Adapter methods'

  describe '#data' do
    include_examples 'should have reader', :data, -> { be == raw_data }
  end

  describe '#null_query' do
    let(:null_query) { adapter.null_query(collection_name: 'books') }

    it { expect(null_query).to be_a Bronze::Collections::NullQuery }
  end

  describe '#query' do
    let(:query) { adapter.query(collection_name: 'books') }

    it { expect(adapter.query(collection_name: 'books')).to be_a query_class }

    it { expect(query.send(:data)).to be == raw_data['books'] }

    wrap_context 'when the data has many items' do
      it { expect(query.send(:data)).to be == raw_data['books'] }
    end
  end
end
