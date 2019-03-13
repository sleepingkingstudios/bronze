# frozen_string_literal: true

require 'date'

require 'bronze/collections/errors'
require 'bronze/collections/simple/adapter'
require 'bronze/repository'

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
        'issue'    => 2,
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
    Bronze::Repository.new(adapter: adapter)
  end
  let(:collection) do
    repository.collection(
      'periodicals',
      primary_key:      :id,
      primary_key_type: Integer
    )
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
  end

  describe 'deleting data by primary key' do
    let(:result) { collection.delete_one(primary_key_value) }

    describe 'with a primary key that does not match an item' do
      let(:primary_key_value) { 13 }
      let(:expected_error)    { Bronze::Collections::Errors.not_found }

      it { expect(result).to be_a_failing_result.with_errors(expected_error) }

      it 'should not change the collection count' do
        expect { collection.delete_one(primary_key_value) }
          .not_to change(collection, :count)
      end

      it 'should not change the collection data' do
        expect { collection.delete_one(primary_key_value) }
          .not_to change(collection.query, :to_a)
      end
    end

    describe 'with a primary key that matches an item' do
      let(:primary_key_value) { 9 }
      let!(:expected_value) do
        periodicals.find { |item| item['id'] == primary_key_value }
      end

      it { expect(result).to be_a_passing_result.with_value(expected_value) }

      it 'should change the collection count' do
        expect { collection.delete_one(primary_key_value) }
          .to change(collection, :count)
          .by(-1)
      end

      it 'should remove the item from the collection' do
        expect { collection.delete_one(primary_key_value) }
          .to change(collection.query, :to_a)
          .to(satisfy { |ary| !ary.include?(expected_value) })
      end
    end
  end

  describe 'deleting data matching a selector' do
    let!(:matching) do
      periodicals.select do |item|
        item >= tools.hash.convert_keys_to_strings(selector)
      end
    end
    let(:nonmatching) do
      periodicals - matching
    end

    def find_periodical(id)
      collection.matching(id: id).to_a.first
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    describe 'with a selector that does not match any items' do
      let(:selector) { { title: 'Triskadecaphobia Today' } }
      let(:result)   { collection.delete_matching(selector) }

      it 'should not change the collection count' do
        expect { collection.delete_matching(selector) }
          .not_to change(collection, :count)
      end

      it 'should not change the collection data' do
        expect { collection.delete_matching(selector) }
          .not_to change(collection.query, :to_a)
      end

      it 'should return a result' do
        expect(result).to be_a_passing_result.with_value(matching)
      end
    end

    describe 'with a selector that matches one item' do
      let(:selector) { { id: 9 } }
      let(:result)   { collection.delete_matching(selector) }

      it 'should change the collection count' do
        expect { collection.delete_matching(selector) }
          .to change(collection, :count)
          .by(-matching.size)
      end

      it 'should delete the matching items' do
        collection.delete_matching(selector)

        matching.each do |matching_item|
          periodical = find_periodical(matching_item['id'])

          expect(periodical).to be nil
        end
      end

      it 'should not delete the non-matching items' do
        collection.delete_matching(selector)

        nonmatching.each do |non_matching_item|
          periodical = find_periodical(non_matching_item['id'])

          expect(periodical).not_to be nil
        end
      end

      it 'should return a result' do
        expect(result).to be_a_passing_result.with_value(matching)
      end
    end

    describe 'with a selector that matches many items' do
      let(:selector) { { title: 'Modern Mentalism' } }
      let(:result)   { collection.delete_matching(selector) }

      it 'should change the collection count' do
        expect { collection.delete_matching(selector) }
          .to change(collection, :count)
          .by(-matching.size)
      end

      it 'should delete the matching items' do
        collection.delete_matching(selector)

        matching.each do |matching_item|
          periodical = find_periodical(matching_item['id'])

          expect(periodical).to be nil
        end
      end

      it 'should not delete the non-matching items' do
        collection.delete_matching(selector)

        nonmatching.each do |non_matching_item|
          periodical = find_periodical(non_matching_item['id'])

          expect(periodical).not_to be nil
        end
      end

      it 'should return a result' do
        expect(result).to be_a_passing_result.with_value(matching)
      end
    end
  end

  describe 'finding data by primary key' do
    let(:result) { collection.find_one(primary_key_value) }

    describe 'with a primary key that does not match an item' do
      let(:primary_key_value) { 13 }
      let(:expected_error)    { Bronze::Collections::Errors.not_found }

      it { expect(result).to be_a_failing_result.with_errors(expected_error) }
    end

    describe 'with a primary key that matches an item' do
      let(:primary_key_value) { 3 }
      let(:expected_item) do
        periodicals.find { |item| item['id'] == primary_key_value }
      end

      it { expect(result).to be_a_passing_result.with_value(expected_item) }
    end
  end

  describe 'finding data matching a selector' do
    let(:matching) do
      periodicals.select do |item|
        item >= tools.hash.convert_keys_to_strings(selector)
      end
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    describe 'with a selector that does not match any items' do
      let(:selector) { { title: 'Triskadecaphobia Today' } }
      let(:result)   { collection.find_matching(selector) }

      it 'should not change the collection data' do
        expect { collection.find_matching(selector) }
          .not_to change(collection.query, :to_a)
      end

      it 'should return a result' do
        expect(result).to be_a_passing_result.with_value(matching)
      end
    end

    describe 'with a selector that matches one item' do
      let(:selector) { { id: 9 } }
      let(:result)   { collection.find_matching(selector) }

      it 'should not change the collection data' do
        expect { collection.find_matching(selector) }
          .not_to change(collection.query, :to_a)
      end

      it 'should return a result' do
        expect(result).to be_a_passing_result.with_value(matching)
      end
    end

    describe 'with a selector that matches many items' do
      let(:selector) { { title: 'Modern Mentalism' } }
      let(:result)   { collection.find_matching(selector) }

      it 'should not change the collection data' do
        expect { collection.find_matching(selector) }
          .not_to change(collection.query, :to_a)
      end

      it 'should return a result' do
        expect(result).to be_a_passing_result.with_value(matching)
      end
    end
  end

  describe 'inserting data into the collection' do
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

      it { expect(result).to be_a_passing_result.with_value(data) }

      it 'should change the collection count' do
        expect { collection.insert_one(data) }
          .to change(collection, :count).by(1)
      end

      it 'should insert the item into the collection' do
        expect { collection.insert_one(data) }
          .to change(collection.query, :to_a)
          .to include(data)
      end
    end
  end

  describe 'querying the data matching a selector' do
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

      describe 'with an ordering' do
        let(:query) { super().order(headline: :asc) }
        let(:expected) do
          super().sort_by { |hsh| hsh['headline'] }
        end

        it { expect(query.count).to be expected.size }

        it { expect(query.to_a).to be == expected }
      end
    end
  end

  describe 'updating data by primary key' do
    let(:primary_key) { nil }
    let(:data)        { { 'publisher' => 'Miskatonic University Press' } }
    let(:result)      { collection.update_one(primary_key, with: data) }

    def find_periodical(id)
      collection.matching(id: id).to_a.first
    end

    describe 'with a primary key that does not match an item' do
      let(:primary_key)    { 13 }
      let(:expected_error) { Bronze::Collections::Errors.not_found }

      it { expect(result).to be_a_failing_result.with_errors(expected_error) }

      it 'should not update the collection' do
        expect { collection.update_one(primary_key, with: data) }
          .not_to change(collection.query, :to_a)
      end
    end

    describe 'with a primary key that matches an item' do
      let(:primary_key) { 9 }
      let(:expected) do
        periodicals.find { |item| item['id'] == primary_key }.merge(data)
      end

      it { expect(result).to be_a_passing_result.with_value(expected) }

      it 'should update the matching item' do
        collection.update_one(primary_key, with: data)

        expect(find_periodical(primary_key)).to be == expected
      end
    end
  end

  describe 'updating data matching a selector' do
    let(:expected) { matching.map { |item| item.merge(data) } }
    let(:matching) do
      periodicals.select do |item|
        item >= tools.hash.convert_keys_to_strings(selector)
      end
    end
    let(:nonmatching) do
      periodicals - matching
    end

    def find_periodical(id)
      collection.matching(id: id).to_a.first
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    describe 'with a selector that does not match any items' do
      let(:data)     { { 'publisher' => 'Miskatonic University Press' } }
      let(:selector) { { title: 'Triskadecaphobia Today' } }
      let(:result)   { collection.update_matching(selector, with: data) }

      it { expect(result).to be_a_passing_result.with_value(expected) }

      it 'should not change the collection count' do
        expect { collection.update_matching(selector, with: data) }
          .not_to change(collection, :count)
      end

      it 'should not change the collection data' do
        expect { collection.update_matching(selector, with: data) }
          .not_to change(collection.query, :to_a)
      end
    end

    describe 'with a selector that matches one item' do
      let(:data)     { { 'publisher' => 'Miskatonic University Press' } }
      let(:selector) { { id: 9 } }
      let(:result)   { collection.update_matching(selector, with: data) }

      it { expect(result).to be_a_passing_result.with_value(expected) }

      it 'should not change the collection count' do
        expect { collection.update_matching(selector, with: data) }
          .not_to change(collection, :count)
      end

      it 'should update the matching items' do
        collection.update_matching(selector, with: data)

        matching.each do |matching_item|
          periodical = find_periodical(matching_item['id'])

          expect(periodical).to be >= data
        end
      end

      it 'should not update the non-matching items' do
        collection.update_matching(selector, with: data)

        nonmatching.each do |non_matching_item|
          periodical = find_periodical(non_matching_item['id'])

          expect(periodical).not_to be >= data
        end
      end
    end

    describe 'with a selector that matches many items' do
      let(:data)     { { 'publisher' => 'Miskatonic University Press' } }
      let(:selector) { { title: 'Modern Mentalism' } }
      let(:result)   { collection.update_matching(selector, with: data) }

      it { expect(result).to be_a_passing_result.with_value(expected) }

      it 'should not change the collection count' do
        expect { collection.update_matching(selector, with: data) }
          .not_to change(collection, :count)
      end

      it 'should update the matching items' do
        collection.update_matching(selector, with: data)

        matching.each do |matching_item|
          periodical = find_periodical(matching_item['id'])

          expect(periodical).to be >= data
        end
      end

      it 'should not update the non-matching items' do
        collection.update_matching(selector, with: data)

        nonmatching.each do |non_matching_item|
          periodical = find_periodical(non_matching_item['id'])

          expect(periodical).not_to be >= data
        end
      end
    end
  end
end
