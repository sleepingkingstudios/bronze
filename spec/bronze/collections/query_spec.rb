# frozen_string_literal: true

require 'bronze/collections/query'

require 'support/examples/collections/query_examples'

RSpec.describe Bronze::Collections::Query do
  include Spec::Support::Examples::Collections::QueryExamples

  subject(:query) { described_class.new }

  include_examples 'should implement the Query interface'

  describe '#count' do
    let(:error_message) do
      'Bronze::Collections::Query#count is not implemented'
    end

    it 'should raise an error' do
      expect { query.count }
        .to raise_error Bronze::NotImplementedError, error_message
    end
  end

  describe '#each' do
    let(:error_message) do
      'Bronze::Collections::Query#each is not implemented'
    end

    it 'should raise an error' do
      expect { query.each }
        .to raise_error Bronze::NotImplementedError, error_message
    end

    describe 'with a block' do
      it 'should raise an error' do
        expect { query.each { |_item| } }
          .to raise_error Bronze::NotImplementedError, error_message
      end
    end
  end

  describe '#matching' do
    let(:error_message) do
      'Bronze::Collections::Query#matching is not implemented'
    end

    it 'should raise an error' do
      expect { query.matching({}) }
        .to raise_error Bronze::NotImplementedError, error_message
    end
  end

  describe '#to_a' do
    let(:error_message) do
      'Bronze::Collections::Query#each is not implemented'
    end

    it 'should raise an error' do
      expect { query.to_a }
        .to raise_error Bronze::NotImplementedError, error_message
    end
  end
end
