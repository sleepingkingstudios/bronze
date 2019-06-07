# frozen_string_literal: true

require 'date'

require 'bronze/collections/errors'
require 'bronze/collections/simple/adapter'
require 'bronze/repository'
require 'bronze/transforms/entities/normalize_transform'

require 'support/entities/examples/periodical'

RSpec.describe Bronze::Collections::Simple do
  shared_context 'when configured for an entity class' do
    let(:entity_class) { Spec::Periodical }
    let(:transform) do
      Bronze::Transforms::Entities::NormalizeTransform.new(entity_class)
    end
    let(:collection) do
      repository.collection(
        'periodicals',
        primary_key:      :id,
        primary_key_type: Integer,
        transform:        transform
      )
    end
  end

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

  def find_by_id(id)
    periodicals.find { |item| item['id'] == id }
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
      let!(:expected_value)   { find_by_id(primary_key_value) }

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

    wrap_context 'when configured for an entity class' do
      pending
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

      it 'should return a passing result' do
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

      it 'should return a passing result' do
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

      it 'should return a passing result' do
        expect(result).to be_a_passing_result.with_value(matching)
      end
    end

    wrap_context 'when configured for an entity class' do
      pending
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
      let!(:expected_value)   { find_by_id(primary_key_value) }

      it { expect(result).to be_a_passing_result.with_value(expected_value) }
    end

    wrap_context 'when configured for an entity class' do
      describe 'with a primary key that does not match an item' do
        let(:primary_key_value) { 13 }
        let(:expected_error)    { Bronze::Collections::Errors.not_found }

        it { expect(result).to be_a_failing_result.with_errors(expected_error) }
      end

      describe 'with a primary key that matches an item' do
        let(:primary_key_value) { 3 }
        let(:expected_value) do
          transform.denormalize(find_by_id(primary_key_value))
        end

        it { expect(result).to be_a_passing_result }

        it { expect(result.value).to be == expected_value }
      end
    end
  end

  describe 'finding data matching a selector' do
    let(:matching) do
      periodicals.select { |item| matches_selector?(selector, item) }
    end
    let(:options) { {} }

    def change_collection_data
      query = Bronze::Collections::Simple::Query.new(adapter.data)

      change(query, :to_a)
    end

    def matches_selector?(selector, item)
      item >= tools.hash.convert_keys_to_strings(selector)
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    describe 'with a selector that does not match any items' do
      let(:selector) { { title: 'Triskadecaphobia Today' } }
      let(:result)   { collection.find_matching(selector) }

      it 'should not change the collection data' do
        expect { collection.find_matching(selector) }
          .not_to change_collection_data
      end

      it 'should return a passing result' do
        expect(result).to be_a_passing_result.with_value(matching)
      end
    end

    describe 'with a selector that matches one item' do
      let(:selector) { { id: 9 } }
      let(:result)   { collection.find_matching(selector) }

      it 'should not change the collection data' do
        expect { collection.find_matching(selector) }
          .not_to change_collection_data
      end

      it 'should return a passing result' do
        expect(result).to be_a_passing_result.with_value(matching)
      end
    end

    describe 'with a selector that matches many items' do
      let(:selector) { { title: 'Modern Mentalism' } }
      let(:result)   { collection.find_matching(selector, **options) }

      it 'should not change the collection data' do
        expect { collection.find_matching(selector) }
          .not_to change_collection_data
      end

      it 'should return a passing result' do
        expect(result).to be_a_passing_result.with_value(matching)
      end

      describe 'with limit: 2' do
        let(:matching) { super()[0...2] }
        let(:options)  { super().merge limit: 2 }

        it 'should not change the collection data' do
          expect { collection.find_matching(selector, limit: 2) }
            .not_to change_collection_data
        end

        it 'should return a passing result' do
          expect(result).to be_a_passing_result.with_value(matching)
        end
      end

      describe 'with offset: 1' do
        let(:matching) { super()[1..-1] }
        let(:options)  { super().merge offset: 1 }

        it 'should not change the collection data' do
          expect { collection.find_matching(selector, offset: 1) }
            .not_to change_collection_data
        end

        it 'should return a passing result' do
          expect(result).to be_a_passing_result.with_value(matching)
        end
      end

      describe 'with order: :title' do
        let(:matching) do
          Spec::Support::Sorting.sort_hashes(super(), title: :asc)
        end
        let(:options) { super().merge order: :title }

        it 'should not change the collection data' do
          expect { collection.find_matching(selector, offset: 1) }
            .not_to change_collection_data
        end

        it 'should return a passing result' do
          expect(result).to be_a_passing_result.with_value(matching)
        end
      end

      describe 'with multiple options' do
        let(:matching) do
          Spec::Support::Sorting.sort_hashes(super(), title: :asc)[1..1]
        end
        let(:options) { super().merge limit: 1, offset: 1, order: :title }

        it 'should not change the collection data' do
          expect { collection.find_matching(selector, offset: 1) }
            .not_to change_collection_data
        end

        it 'should return a passing result' do
          expect(result).to be_a_passing_result.with_value(matching)
        end
      end
    end

    wrap_context 'when configured for an entity class' do
      let(:matching) do
        periodicals
          .select { |item| matches_selector?(selector, item) }
          .map { |item| transform.denormalize(item) }
      end

      describe 'with a selector that does not match any items' do
        let(:selector) { { title: 'Triskadecaphobia Today' } }
        let(:result)   { collection.find_matching(selector) }

        it 'should not change the collection data' do
          expect { collection.find_matching(selector) }
            .not_to change_collection_data
        end

        it 'should return a passing result' do
          expect(result).to be_a_passing_result.with_value(matching)
        end
      end

      describe 'with a selector that matches one item' do
        let(:selector) { { id: 9 } }
        let(:result)   { collection.find_matching(selector) }

        it 'should not change the collection data' do
          expect { collection.find_matching(selector) }
            .not_to change_collection_data
        end

        it 'should return a passing result' do
          expect(result).to be_a_passing_result.with_value(matching)
        end
      end

      describe 'with a selector that matches many items' do
        let(:selector) { { title: 'Modern Mentalism' } }
        let(:result)   { collection.find_matching(selector, **options) }

        it 'should not change the collection data' do
          expect { collection.find_matching(selector) }
            .not_to change_collection_data
        end

        it 'should return a passing result' do
          expect(result).to be_a_passing_result.with_value(matching)
        end

        describe 'with limit: 2' do
          let(:matching) { super()[0...2] }
          let(:options)  { super().merge limit: 2 }

          it 'should not change the collection data' do
            expect { collection.find_matching(selector, limit: 2) }
              .not_to change_collection_data
          end

          it 'should return a passing result' do
            expect(result).to be_a_passing_result.with_value(matching)
          end
        end

        describe 'with offset: 1' do
          let(:matching) { super()[1..-1] }
          let(:options)  { super().merge offset: 1 }

          it 'should not change the collection data' do
            expect { collection.find_matching(selector, offset: 1) }
              .not_to change_collection_data
          end

          it 'should return a passing result' do
            expect(result).to be_a_passing_result.with_value(matching)
          end
        end

        describe 'with order: :title' do
          let(:matching) do
            Spec::Support::Sorting.sort_hashes(super(), title: :asc)
          end
          let(:options) { super().merge order: :title }

          it 'should not change the collection data' do
            expect { collection.find_matching(selector, offset: 1) }
              .not_to change_collection_data
          end

          it 'should return a passing result' do
            expect(result).to be_a_passing_result.with_value(matching)
          end
        end

        describe 'with multiple options' do
          let(:matching) do
            Spec::Support::Sorting.sort_hashes(super(), title: :asc)[1..1]
          end
          let(:options) { super().merge limit: 1, offset: 1, order: :title }

          it 'should not change the collection data' do
            expect { collection.find_matching(selector, offset: 1) }
              .not_to change_collection_data
          end

          it 'should return a passing result' do
            expect(result).to be_a_passing_result.with_value(matching)
          end
        end
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

    wrap_context 'when configured for an entity class' do
      describe 'with a valid entity' do
        let(:entity) do
          Spec::Periodical.new(
            'id'       => 13,
            'title'    => 'Triskadecaphobia Today',
            'issue'    => 13,
            'headline' => '13 Reasons To Fear The Number Thirteen',
            'date'     => Date.new(2013, 1, 3)
          )
        end
        let(:result) { collection.insert_one(entity) }

        it { expect(result).to be_a_passing_result.with_value(entity) }

        it 'should change the collection count' do
          expect { collection.insert_one(entity) }
            .to change(collection, :count).by(1)
        end

        it 'should insert the item into the collection' do
          expect { collection.insert_one(entity) }
            .to change(collection.query, :to_a)
            .to include(entity)
        end
      end
    end
  end

  describe 'querying all data' do
    let(:matching) { periodicals }
    let(:expected) { matching }

    it { expect(collection.all.count).to be expected.size }

    it { expect(collection.all.to_a).to be == expected }

    describe 'with a simple ordering' do
      let(:query) { collection.all.order(:headline) }
      let(:matching) do
        Spec::Support::Sorting.sort_hashes(periodicals, 'headline' => :asc)
      end

      it { expect(query.count).to be expected.size }

      it { expect(query.to_a).to be == expected }
    end

    describe 'with a complex ordering' do
      let(:query) { collection.all.order(:issue, headline: :desc) }
      let(:matching) do
        Spec::Support::Sorting.sort_hashes(
          periodicals,
          'issue'    => :asc,
          'headline' => :desc
        )
      end

      it { expect(query.count).to be expected.size }

      it { expect(query.to_a).to be == expected }
    end

    describe 'with an ordering with a limit' do
      let(:query) { collection.all.order(:headline).limit(4).offset(2) }
      let(:matching) do
        Spec::Support::Sorting
          .sort_hashes(periodicals, 'headline' => :asc)[2...6]
      end

      it { expect(query.count).to be expected.size }

      it { expect(query.to_a).to be == expected }
    end

    wrap_context 'when configured for an entity class' do
      let(:expected) { matching.map { |item| transform.denormalize(item) } }

      describe 'with a simple ordering' do
        let(:query) { collection.all.order(:headline) }
        let(:matching) do
          Spec::Support::Sorting.sort_hashes(periodicals, 'headline' => :asc)
        end

        it { expect(query.count).to be expected.size }

        it { expect(query.to_a).to be == expected }
      end

      describe 'with a complex ordering' do
        let(:query) { collection.all.order(:issue, headline: :desc) }
        let(:matching) do
          Spec::Support::Sorting.sort_hashes(
            periodicals,
            'issue'    => :asc,
            'headline' => :desc
          )
        end

        it { expect(query.count).to be expected.size }

        it { expect(query.to_a).to be == expected }
      end

      describe 'with an ordering with a limit' do
        let(:query) { collection.all.order(:headline).limit(4).offset(2) }
        let(:matching) do
          Spec::Support::Sorting
            .sort_hashes(periodicals, 'headline' => :asc)[2...6]
        end

        it { expect(query.count).to be expected.size }

        it { expect(query.to_a).to be == expected }
      end
    end
  end

  describe 'querying the data matching a selector' do
    let(:matching) { periodicals }
    let(:expected) { matching }

    describe 'with an empty selector' do
      let(:query) { collection.matching({}) }

      it { expect(query.count).to be expected.size }

      it { expect(query.to_a).to be == expected }
    end

    describe 'with a selector that does not match any items' do
      let(:query) { collection.matching('title' => 'Crystal Digest') }

      it { expect(query.count).to be 0 }

      it { expect(query.to_a).to be == [] }
    end

    describe 'with a selector that matches one item' do
      let(:query) { collection.matching(id: 9) }
      let(:matching) do
        periodicals.select { |hsh| hsh['id'] == 9 }
      end

      it { expect(query.count).to be expected.size }

      it { expect(query.to_a).to be == expected }
    end

    describe 'with a selector that matches some items' do
      let(:query) { collection.matching('title' => 'Modern Mentalism') }
      let(:matching) do
        periodicals.select { |hsh| hsh['title'] == 'Modern Mentalism' }
      end

      it { expect(query.count).to be expected.size }

      it { expect(query.to_a).to be == expected }

      describe 'with a simple ordering' do
        let(:query) { super().order(:headline) }
        let(:matching) do
          Spec::Support::Sorting.sort_hashes(super(), 'headline' => :asc)
        end

        it { expect(query.count).to be expected.size }

        it { expect(query.to_a).to be == expected }
      end

      describe 'with a complex ordering' do
        let(:query) { super().order(:issue, headline: :desc) }
        let(:matching) do
          Spec::Support::Sorting.sort_hashes(
            super(),
            'issue'    => :asc,
            'headline' => :desc
          )
        end

        it { expect(query.count).to be expected.size }

        it { expect(query.to_a).to be == expected }
      end

      describe 'with an ordering with a limit' do
        let(:query) { super().order(:headline).limit(4).offset(2) }
        let(:matching) do
          Spec::Support::Sorting.sort_hashes(super(), 'headline' => :asc)[2...6]
        end

        it { expect(query.count).to be expected.size }

        it { expect(query.to_a).to be == expected }
      end
    end

    wrap_context 'when configured for an entity class' do
      let(:expected) { matching.map { |item| transform.denormalize(item) } }

      describe 'with an empty selector' do
        let(:query) { collection.matching({}) }

        it { expect(query.count).to be expected.size }

        it { expect(query.to_a).to be == expected }
      end

      describe 'with a selector that does not match any items' do
        let(:query) { collection.matching('title' => 'Crystal Digest') }

        it { expect(query.count).to be 0 }

        it { expect(query.to_a).to be == [] }
      end

      describe 'with a selector that matches one item' do
        let(:query) { collection.matching(id: 9) }
        let(:matching) do
          periodicals.select { |hsh| hsh['id'] == 9 }
        end

        it { expect(query.count).to be expected.size }

        it { expect(query.to_a).to be == expected }
      end

      describe 'with a selector that matches some items' do
        let(:query) { collection.matching('title' => 'Modern Mentalism') }
        let(:matching) do
          periodicals.select { |hsh| hsh['title'] == 'Modern Mentalism' }
        end

        it { expect(query.count).to be expected.size }

        it { expect(query.to_a).to be == expected }

        describe 'with a simple ordering' do
          let(:query) { super().order(:headline) }
          let(:matching) do
            Spec::Support::Sorting.sort_hashes(super(), 'headline' => :asc)
          end

          it { expect(query.count).to be expected.size }

          it { expect(query.to_a).to be == expected }
        end

        describe 'with a complex ordering' do
          let(:query) { super().order(:issue, headline: :desc) }
          let(:matching) do
            Spec::Support::Sorting.sort_hashes(
              super(),
              'issue'    => :asc,
              'headline' => :desc
            )
          end

          it { expect(query.count).to be expected.size }

          it { expect(query.to_a).to be == expected }
        end

        describe 'with an ordering with a limit' do
          let(:query) { super().order(:headline).limit(4).offset(2) }
          let(:matching) do
            Spec::Support::Sorting
              .sort_hashes(super(), 'headline' => :asc)[2...6]
          end

          it { expect(query.count).to be expected.size }

          it { expect(query.to_a).to be == expected }
        end
      end
    end
  end

  describe 'updating data by primary key' do
    let(:expected_value) { nil }
    let(:data)           { { 'publisher' => 'Miskatonic University Press' } }
    let(:result) do
      collection.update_one(primary_key_value, with: data)
    end

    def find_periodical(id)
      collection.matching(id: id).to_a.first
    end

    describe 'with a primary key that does not match an item' do
      let(:primary_key_value) { 13 }
      let(:expected_error)    { Bronze::Collections::Errors.not_found }

      it { expect(result).to be_a_failing_result.with_errors(expected_error) }

      it 'should not update the collection' do
        expect { collection.update_one(primary_key_value, with: data) }
          .not_to change(collection.query, :to_a)
      end
    end

    describe 'with a primary key that matches an item' do
      let(:primary_key_value) { 9 }
      let(:expected_value) do
        find_by_id(primary_key_value).merge(data)
      end

      it { expect(result).to be_a_passing_result.with_value(expected_value) }

      it 'should update the matching item' do
        collection.update_one(primary_key_value, with: data)

        expect(find_periodical(primary_key_value)).to be == expected_value
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

    wrap_context 'when configured for an entity class' do
      pending
    end
  end
end
