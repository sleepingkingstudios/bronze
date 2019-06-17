# frozen_string_literal: true

require 'bronze/collections/query'
require 'bronze/transforms/identity_transform'

require 'support/examples/collections/query_examples'

RSpec.describe Bronze::Collections::Query do
  include Spec::Support::Examples::Collections::QueryExamples

  subject(:query) { described_class.new }

  include_examples 'should implement the Query interface'

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:transform)
    end
  end

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

  describe '#exists?' do
    let(:error_message) do
      'Bronze::Collections::Query#limit is not implemented'
    end

    it 'should raise an error' do
      expect { query.exists? }
        .to raise_error Bronze::NotImplementedError, error_message
    end
  end

  describe '#limit' do
    let(:error_message) do
      'Bronze::Collections::Query#limit is not implemented'
    end

    it 'should raise an error' do
      expect { query.limit(3) }
        .to raise_error Bronze::NotImplementedError, error_message
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

  describe '#none' do
    let(:error_message) do
      'Bronze::Collections::Query#none is not implemented'
    end

    it 'should raise an error' do
      expect { query.none }
        .to raise_error Bronze::NotImplementedError, error_message
    end
  end

  describe '#offset' do
    let(:error_message) do
      'Bronze::Collections::Query#offset is not implemented'
    end

    it 'should raise an error' do
      expect { query.offset(0) }
        .to raise_error Bronze::NotImplementedError, error_message
    end
  end

  describe '#order' do
    let(:error_message) do
      'Bronze::Collections::Query#order is not implemented'
    end

    it 'should raise an error' do
      expect { query.order({}) }
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

  describe '#transform' do
    it { expect(query.transform).to be nil }

    context 'when initialized with transform: value' do
      subject(:query) { described_class.new(transform: transform) }

      let(:transform) { Bronze::Transforms::IdentityTransform.new }

      it { expect(query.transform).to be transform }
    end
  end
end
