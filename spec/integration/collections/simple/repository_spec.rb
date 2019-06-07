# frozen_string_literal: true

require 'bronze/collections/simple/adapter'
require 'bronze/repository'
require 'bronze/transforms/entities/normalize_transform'

require 'support/entities/examples/basic_book'
require 'support/entities/examples/periodical'

RSpec.describe Bronze::Repository do
  let(:periodicals) do
    [
      {
        'id'    => 0,
        'title' => 'Magazine Order Form'
      }
    ]
  end
  let(:adapter) do
    Bronze::Collections::Simple::Adapter.new('periodicals' => periodicals)
  end
  let(:repository) do
    described_class.new(adapter: adapter)
  end

  describe 'accessing a collection' do
    describe 'with an invalid collection name' do
      let(:collection) { repository.collection('books') }

      it { expect(collection).to be_a Bronze::Collection }

      it { expect(collection.adapter).to be adapter }

      it { expect(collection.name).to be == 'books' }

      it { expect(collection.count).to be 0 }
    end

    describe 'with a valid collection name' do
      let(:collection) { repository.collection('periodicals') }

      it { expect(collection).to be_a Bronze::Collection }

      it { expect(collection.adapter).to be adapter }

      it { expect(collection.name).to be == 'periodicals' }

      it { expect(collection.count).to be periodicals.size }
    end

    describe 'with an invalid entity class' do
      let(:collection) do
        repository.collection(Spec::BasicBook)
      end

      it { expect(collection).to be_a Bronze::Collection }

      it { expect(collection.adapter).to be adapter }

      it { expect(collection.name).to be == 'spec__basic_books' }

      it { expect(collection.count).to be 0 }
    end

    describe 'with a valid entity class' do
      let(:entity_class) { Spec::Periodical }
      let(:collection) do
        repository.collection(entity_class, transform: transform)
      end
      let(:transform_class) { Bronze::Transforms::Entities::NormalizeTransform }
      let(:transform) do
        Bronze::Transforms::Entities::NormalizeTransform.new(entity_class)
      end

      it { expect(collection).to be_a Bronze::Collection }

      it { expect(collection.adapter).to be adapter }

      it { expect(collection.name).to be == 'periodicals' }

      it { expect(collection.count).to be periodicals.size }

      it { expect(collection.transform).to be_a transform_class }

      it { expect(collection.transform.entity_class).to be Spec::Periodical }
    end
  end
end
