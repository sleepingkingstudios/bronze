# frozen_string_literal: true

require 'bronze/collections/mongo/query'

require 'support/examples/collections/query_examples'

RSpec.describe Bronze::Collections::Mongo::Query do
  include Spec::Support::Examples::Collections::QueryExamples

  subject(:query) { described_class.new(collection) }

  let(:collection) { Spec.mongo_client[:books] }
  let(:raw_data)   { [] }
  let(:sort_nils_before_values) do
    true # MongoDB sorts nil values before non-nil
  end

  # rubocop:disable RSpec/BeforeAfterAll
  before(:context) do
    Spec.mongo_client[:books].delete_many
  end
  # rubocop:enable RSpec/BeforeAfterAll

  before(:example) do
    # Hack to handle MongoDB automatically adding IDs.
    raw_data.each { |data| data['_id'] = BSON::ObjectId.new }

    collection.insert_many(raw_data)
  end

  after(:example) { collection.delete_many }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end

  describe '#collection' do
    include_examples 'should have private reader',
      :collection,
      -> { collection }
  end

  include_examples 'should implement the Query interface'

  include_examples 'should implement the Query methods'
end
