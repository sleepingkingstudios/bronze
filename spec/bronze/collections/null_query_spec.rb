# frozen_string_literal: true

require 'bronze/collections/null_query'

require 'support/examples/collections/query_examples'

RSpec.describe Bronze::Collections::NullQuery do
  include Spec::Support::Examples::Collections::QueryExamples

  subject(:query) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  include_examples 'should implement the Query interface'

  describe '#count' do
    it { expect(query.count).to be 0 }
  end

  describe '#dup' do
    let(:copied_query) { query.dup }

    it { expect(copied_query.count).to be 0 }

    it { expect(copied_query.to_a).to be == [] }
  end

  describe '#each' do
    it { expect(query.each).to be_a Enumerator }

    it { expect(query.each.to_a).to be == [] }

    describe 'with a block' do
      it 'should not yield control' do
        expect { |block| query.each(&block) }.not_to yield_control
      end
    end
  end

  describe '#exists?' do
    it { expect(query.exists?).to be false }
  end

  describe '#limit' do
    let(:limit)    { 3 }
    let(:subquery) { query.limit(limit) }

    it { expect(query.limit 3).to be query }

    it { expect(subquery.count).to be 0 }

    it { expect(subquery.to_a).to be == [] }
  end

  describe '#matching' do
    let(:selector) { {} }
    let(:subquery) { query.matching(selector) }

    it { expect(query.matching selector).to be query }

    it { expect(subquery.count).to be 0 }

    it { expect(subquery.to_a).to be == [] }
  end

  describe '#none' do
    let(:selector) { {} }
    let(:subquery) { query.none }

    it { expect(query.none).to be query }

    it { expect(subquery.count).to be 0 }

    it { expect(subquery.to_a).to be == [] }
  end

  describe '#offset' do
    let(:offset)   { 3 }
    let(:subquery) { query.offset(offset) }

    it { expect(query.offset 3).to be query }

    it { expect(subquery.count).to be 0 }

    it { expect(subquery.to_a).to be == [] }
  end

  describe '#order' do
    let(:attributes)    { %w[title] }
    let(:subquery)      { query.order(*attributes) }

    it { expect(query.order(*attributes)).to be query }

    it { expect(subquery.count).to be 0 }

    it { expect(subquery.to_a).to be == [] }
  end

  describe '#to_a' do
    it { expect(query.to_a).to be == [] }
  end
end
