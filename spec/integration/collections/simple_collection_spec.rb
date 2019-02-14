# frozen_string_literal: true

require 'date'

require 'bronze/collections/repository'
require 'bronze/collections/simple/adapter'

RSpec.describe Bronze::Collections::Simple do
  let(:periodicals) do
    [
      {
        'id'    => 0,
        'title' => 'Magazine Order Form'
      },
      {
        'id'       => 1,
        'title'    => 'Modern Mentalism',
        'issue'    => 1,
        'headline' => 'Unlocking the Secrets of the Mind',
        'date'     => Date.new(1960, 1, 1)
      },
      {
        'id'       => 2,
        'title'    => 'Modern Mentalism',
        'issue'    => 2,
        'headline' => 'Hands-Free Dowsing',
        'date'     => Date.new(1960, 2, 1)
      },
      {
        'id'       => 3,
        'title'    => 'Modern Mentalism',
        'issue'    => 3,
        'headline' => 'Harnessing Crystalline Energy',
        'date'     => Date.new(1960, 3, 1)
      },
      {
        'id'       => 4,
        'title'    => 'Modern Mentalism',
        'issue'    => 4,
        'headline' => 'Communicating With Your Past Lives',
        'date'     => Date.new(1960, 4, 1)
      },
      {
        'id'       => 5,
        'title'    => 'Modern Mentalism',
        'issue'    => 5,
        'headline' => 'The Greys - Friend or Foe?',
        'date'     => Date.new(1960, 5, 1)
      },
      {
        'id'       => 6,
        'title'    => 'Modern Mentalism',
        'issue'    => 6,
        'headline' => 'How We Know The Earth To Be Banana-Shaped',
        'date'     => Date.new(1960, 6, 1)
      },
      {
        'id'       => 7,
        'title'    => 'Secrets of the Mummies',
        'issue'    => 1,
        'headline' => 'These 4th Dynasty Pharoahs Were Secretly From Proxima ' \
                      'Centauri. Number Four Will Shock You!',
        'date'     => Date.new(1950, 1, 1)
      },
      {
        'id'       => 8,
        'title'    => 'Secrets of the Mummies',
        'issue'    => 1,
        'headline' => 'The Pyramids - Granary, Or Interplanetary Landing ' \
                      'Beacon? You Decide!',
        'date'     => Date.new(1950, 2, 1)
      },
      {
        'id'       => 9,
        'title'    => 'Secrets of the Mummies',
        'headline' => 'The Swimsuit Edition',
        'date'     => Date.new(1950, 3, 1)
      },
      {
        'id'       => 10,
        'title'    => 'Annals of Parapsychology',
        'issue'    => 1,
        'headline' => 'Putting Stress Behind You',
        'date'     => Date.new(1970, 2, 1)
      },
      {
        'id'       => 11,
        'title'    => 'Annals of Parapsychology',
        'issue'    => 2,
        'headline' => "Letting Go Of What's Inside",
        'date'     => Date.new(1970, 3, 1)
      },
      {
        'id'       => 12,
        'title'    => 'Annals of Parapsychology',
        'issue'    => 3,
        'headline' => 'Charting The Influence of Uranus',
        'date'     => Date.new(1970, 4, 1)
      }
    ]
  end
  let(:adapter) do
    Bronze::Collections::Simple::Adapter.new('periodicals' => periodicals)
  end
  let(:repository) do
    Bronze::Collections::Repository.new(adapter: adapter)
  end

  describe 'accessing a collection' do
    describe 'with an invalid collection name' do
      let(:collection) { repository.collection('books') }

      it { expect(collection).to be_a Bronze::Collections::Collection }

      it { expect(collection.adapter).to be adapter }

      it { expect(collection.name).to be == 'books' }

      it { expect(collection.count).to be 0 }
    end

    describe 'with a valid collection name' do
      let(:collection) { repository.collection('periodicals') }

      it { expect(collection).to be_a Bronze::Collections::Collection }

      it { expect(collection.adapter).to be adapter }

      it { expect(collection.name).to be == 'periodicals' }

      it { expect(collection.count).to be periodicals.size }
    end
  end

  describe 'inserting data into the collection' do
    let(:collection) { repository.collection('periodicals') }

    describe 'with a valid data hash' do
      let(:data) do
        {
          'id'       => 13,
          'title'    => 'Triskadecaphobia Today',
          'issue'    => 13,
          'headline' => '13 Reasons To Fear The Number Thirteen',
          'date'     => Date.new(2013, 1, 3)
        }
      end
      let(:result) { collection.insert_one(data) }

      it { expect(result).to be_a Array }

      it { expect(result.size).to be 3 }

      it { expect(result[0]).to be true }

      it { expect(result[1]).to be == data }

      it { expect(result[2]).to be_a Bronze::Errors }

      it { expect(result[2]).to be_empty }
    end
  end

  describe 'querying the data' do
    let(:collection) { repository.collection('periodicals') }

    it { expect(collection.all.count).to be periodicals.size }

    it { expect(collection.all.to_a).to be == periodicals }

    describe 'with a value matcher that does not match any items' do
      let(:query) { collection.matching('title' => 'Crystal Digest') }

      it { expect(query.count).to be 0 }

      it { expect(query.to_a).to be == [] }
    end

    describe 'with a value matcher that matches some items' do
      let(:query) { collection.matching('title' => 'Modern Mentalism') }
      let(:expected) do
        periodicals.select { |hsh| hsh['title'] == 'Modern Mentalism' }
      end

      it { expect(query.count).to be expected.size }

      it { expect(query.to_a).to be == expected }
    end
  end
end