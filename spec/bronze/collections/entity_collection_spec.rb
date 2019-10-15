# frozen_string_literal: true

require 'bronze/collections/adapter'
require 'bronze/collections/entity_collection'
require 'bronze/collections/null_query'
require 'bronze/collections/query'

require 'support/transforms/capitalize_keys_transform'

RSpec.describe Bronze::Collections::EntityCollection do
  shared_context 'when the entity class has an integer primary key' do
    let(:primary_key)       { :id }
    let(:primary_key_type)  { Integer }
    let(:primary_key_value) { 0 }

    before(:example) do
      Spec::ColoringBook.send :include, Bronze::Entities::PrimaryKey

      Spec::ColoringBook.define_primary_key(
        primary_key,
        primary_key_type,
        default: -> { primary_key_value }
      )
    end
  end

  shared_context 'when the entity class has a string primary key' do
    let(:primary_key)       { :hex }
    let(:primary_key_type)  { String }
    let(:primary_key_value) { 'ff' }

    before(:example) do
      Spec::ColoringBook.send :include, Bronze::Entities::PrimaryKey

      Spec::ColoringBook.define_primary_key(
        primary_key,
        primary_key_type,
        default: -> { primary_key_value }
      )
    end
  end

  shared_context 'when initialized with a transform' do
    let(:normalize_transform) do
      Bronze::Transforms::Entities::NormalizeTransform.new(entity_class)
    end
    let(:capitalize_keys_transform) do
      Spec::CapitalizeKeysTransform.new
    end
    let(:transform) do
      capitalize_keys_transform >> normalize_transform
    end
    let(:options) { super().merge(transform: transform) }
  end

  shared_examples 'should delegate to the adapter' do
    let(:result) { Cuprum::Result.new(value: value) }

    it 'delegate to the adapter' do
      call_method

      expect(adapter).to have_received(method_name).with(expected_keywords)
    end

    it 'should return a passing result' do
      allow(adapter).to receive(method_name).and_return(result)

      expect(call_method)
        .to be_a_passing_result
        .with_value(expected)
    end
  end

  shared_examples 'should validate the data object' do
    describe 'with a nil data object' do
      let(:object) { nil }
      let(:expected_error) do
        Bronze::Errors.new.add(
          Bronze::Collections::Errors::DATA_MISSING,
          {}
        )
      end

      it 'should not delegate to the adapter' do
        call_method

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a failing result' do
        expect(call_method)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with a non-entity data object' do
      let(:object) { Object.new }
      let(:expected_error) do
        Bronze::Errors.new.add(
          Bronze::Collections::Errors::DATA_INVALID,
          data: object
        )
      end

      it 'should not delegate to the adapter' do
        call_method

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a failing result' do
        expect(call_method)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end
  end

  shared_examples 'should validate the data object for insertion' do
    include_examples 'should validate the data object'

    describe 'with a data hash' do
      let(:object) { data }
      let(:expected_error) do
        Bronze::Errors.new.add(
          Bronze::Collections::Errors::DATA_INVALID,
          data: object
        )
      end

      it 'should not delegate to the adapter' do
        call_method

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a failing result' do
        expect(call_method)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end
  end

  shared_examples 'should validate the primary key for bulk updates' do
    wrap_context 'when the entity class has an integer primary key' do
      describe 'with a data object that includes the primary key' do
        let(:data) { { primary_key.to_s => primary_key_value } }
        let(:expected_error) do
          Bronze::Errors.new[primary_key].add(
            Bronze::Collections::Errors::PRIMARY_KEY_BULK_UPDATE,
            value: primary_key_value
          )
        end

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end

    wrap_context 'when the entity class has a string primary key' do
      describe 'with a data object that includes the primary key' do
        let(:data) { { primary_key => primary_key_value } }
        let(:expected_error) do
          Bronze::Errors.new[primary_key].add(
            Bronze::Collections::Errors::PRIMARY_KEY_BULK_UPDATE,
            value: primary_key_value
          )
        end

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end
  end

  shared_examples 'should validate the primary key for insertion' do
    wrap_context 'when the entity class has an integer primary key' do
      describe 'with a nil primary key' do
        let(:expected_error) do
          Bronze::Errors.new[primary_key].add(
            Bronze::Collections::Errors::PRIMARY_KEY_MISSING
          )
        end

        before(:example) do
          object.send(:"#{primary_key}=", nil)
        end

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with a primary key with invalid type' do
        let(:primary_key_value) { Object.new }
        let(:data) do
          super().merge(primary_key => primary_key_value)
        end
        let(:expected_error) do
          Bronze::Errors.new[primary_key].add(
            Bronze::Collections::Errors::PRIMARY_KEY_INVALID,
            type:  primary_key_type.name,
            value: primary_key_value.to_s
          )
        end

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end

    wrap_context 'when the entity class has a string primary key' do
      describe 'with a nil primary key' do
        let(:expected_error) do
          Bronze::Errors.new[primary_key].add(
            Bronze::Collections::Errors::PRIMARY_KEY_MISSING
          )
        end

        before(:example) do
          object.send(:"#{primary_key}=", nil)
        end

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with a primary key with invalid type' do
        let(:primary_key_value) { Object.new }
        let(:data) do
          super().merge(primary_key => primary_key_value)
        end
        let(:expected_error) do
          Bronze::Errors.new[primary_key].add(
            Bronze::Collections::Errors::PRIMARY_KEY_INVALID,
            type:  primary_key_type.name,
            value: primary_key_value.to_s
          )
        end

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with an empty primary key' do
        let(:primary_key_value) { '' }
        let(:data) do
          super().merge(primary_key => primary_key_value)
        end
        let(:expected_error) do
          Bronze::Errors.new[primary_key].add(
            Bronze::Collections::Errors::PRIMARY_KEY_EMPTY,
            value: primary_key_value.to_s
          )
        end

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end
  end

  shared_examples 'should validate the primary key for querying' do
    describe 'with a nil primary key' do
      let(:primary_key_value) { nil }
      let(:expected_error) do
        Bronze::Errors.new.add(Bronze::Collections::Errors::NO_PRIMARY_KEY)
      end

      it 'should not delegate to the adapter' do
        call_method

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a failing result' do
        expect(call_method)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with a primary key' do
      let(:primary_key_value) { '00000000-0000-0000-0000-000000000000' }
      let(:expected_error) do
        Bronze::Errors.new.add(Bronze::Collections::Errors::NO_PRIMARY_KEY)
      end

      it 'should not delegate to the adapter' do
        call_method

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a failing result' do
        expect(call_method)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    wrap_context 'when the entity class has an integer primary key' do
      describe 'with a nil primary key' do
        let(:primary_key_value) { nil }
        let(:expected_error) do
          Bronze::Errors.new[primary_key].add(
            Bronze::Collections::Errors::PRIMARY_KEY_MISSING
          )
        end

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with a primary key with invalid type' do
        let(:primary_key_value) { Object.new }
        let(:expected_error) do
          Bronze::Errors.new[primary_key].add(
            Bronze::Collections::Errors::PRIMARY_KEY_INVALID,
            type:  primary_key_type.name,
            value: primary_key_value.to_s
          )
        end

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end

    wrap_context 'when the entity class has a string primary key' do
      describe 'with a nil primary key' do
        let(:primary_key_value) { nil }
        let(:expected_error) do
          Bronze::Errors.new[primary_key].add(
            Bronze::Collections::Errors::PRIMARY_KEY_MISSING
          )
        end

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with a primary key with invalid type' do
        let(:primary_key_value) { Object.new }
        let(:expected_error) do
          Bronze::Errors.new[primary_key].add(
            Bronze::Collections::Errors::PRIMARY_KEY_INVALID,
            type:  primary_key_type.name,
            value: primary_key_value.to_s
          )
        end

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with an empty primary key' do
        let(:primary_key_type)  { String }
        let(:primary_key_value) { '' }
        let(:expected_error) do
          Bronze::Errors.new[primary_key].add(
            Bronze::Collections::Errors::PRIMARY_KEY_EMPTY,
            value: primary_key_value.to_s
          )
        end

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end
  end

  shared_examples 'should validate the primary key for updates' do
    describe 'with a nil primary key' do
      let(:primary_key_value) { nil }
      let(:expected_error) do
        Bronze::Errors.new.add(Bronze::Collections::Errors::NO_PRIMARY_KEY)
      end

      it 'should not delegate to the adapter' do
        call_method

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a failing result' do
        expect(call_method)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with a primary key' do
      let(:primary_key_value) { '00000000-0000-0000-0000-000000000000' }
      let(:expected_error) do
        Bronze::Errors.new.add(Bronze::Collections::Errors::NO_PRIMARY_KEY)
      end

      it 'should not delegate to the adapter' do
        call_method

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a failing result' do
        expect(call_method)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    wrap_context 'when the entity class has an integer primary key' do
      let(:data) { super().merge(primary_key => primary_key_value) }

      describe 'with primary_key: nil' do
        let(:data) { super().merge(primary_key => nil) }
        let(:expected_error) do
          Bronze::Errors.new[primary_key].add(
            Bronze::Collections::Errors::PRIMARY_KEY_CHANGED,
            value: nil
          )
        end

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with primary_key: different value' do
        let(:data) { super().merge(primary_key => 13) }
        let(:expected_error) do
          Bronze::Errors.new[primary_key].add(
            Bronze::Collections::Errors::PRIMARY_KEY_CHANGED,
            value: 13
          )
        end

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with primary_key: same value' do
        let(:data) { super().merge(primary_key => primary_key_value) }

        it 'delegate to the adapter' do
          call_method

          expect(adapter).to have_received(method_name)
        end

        it 'should return a passing result' do
          expect(call_method).to be_a_passing_result
        end
      end
    end

    wrap_context 'when the entity class has a string primary key' do
      let(:data) { super().merge(primary_key => primary_key_value) }

      describe 'with primary_key: nil' do
        let(:data) { super().merge(primary_key => nil) }
        let(:expected_error) do
          Bronze::Errors.new[primary_key].add(
            Bronze::Collections::Errors::PRIMARY_KEY_CHANGED,
            value: nil
          )
        end

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with primary_key: different value' do
        let(:data) do
          super().merge(primary_key => '00000000-0000-0000-0000-00000000000d')
        end
        let(:expected_error) do
          Bronze::Errors.new[primary_key].add(
            Bronze::Collections::Errors::PRIMARY_KEY_CHANGED,
            value: '00000000-0000-0000-0000-00000000000d'
          )
        end

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with primary_key: same value' do
        let(:data) { super().merge(primary_key => primary_key_value) }

        it 'should delegate to the adapter' do
          call_method

          expect(adapter).to have_received(method_name)
        end

        it 'should return a passing result' do
          expect(call_method).to be_a_passing_result
        end
      end
    end
  end

  shared_examples 'should validate the selector' do
    describe 'with a nil selector' do
      let(:selector) { nil }
      let(:expected_error) do
        Bronze::Errors.new.add(
          Bronze::Collections::Errors::SELECTOR_MISSING,
          {}
        )
      end

      it 'should not delegate to the adapter' do
        call_method

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a failing result' do
        expect(call_method)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    describe 'with a non-Hash selector' do
      let(:selector) { Object.new }
      let(:expected_error) do
        Bronze::Errors.new.add(
          Bronze::Collections::Errors::SELECTOR_INVALID,
          selector: selector
        )
      end

      it 'should not delegate to the adapter' do
        call_method

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a failing result' do
        expect(call_method)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end
  end

  subject(:collection) do
    described_class.new(definition, adapter: adapter, **options)
  end

  let(:options)      { {} }
  let(:entity_class) { Spec::ColoringBook }
  let(:definition)   { entity_class }
  let(:adapter) do
    instance_double(
      Bronze::Collections::Adapter,
      collection_name_for: '',
      delete_matching:     Cuprum::Result.new,
      delete_one:          Cuprum::Result.new,
      find_matching:       Cuprum::Result.new,
      find_one:            Cuprum::Result.new,
      insert_one:          Cuprum::Result.new,
      null_query:          null_query,
      query:               query,
      update_matching:     Cuprum::Result.new,
      update_one:          Cuprum::Result.new
    )
  end
  let(:null_query) do
    instance_double(Bronze::Collections::NullQuery)
  end
  let(:query) do
    instance_double(
      Bronze::Collections::Query,
      count:    3,
      each:     [].each,
      matching: subquery
    )
  end
  let(:subquery) { instance_double(Bronze::Collections::Query) }

  example_class 'Spec::ColoringBook', Bronze::Entity do |klass|
    klass.attribute :title,  String
    klass.attribute :author, String
  end

  describe '::new' do
    let(:error_message) do
      'expected definition to be an entity class, but was '
    end

    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(1).argument
        .and_keywords(:adapter, :name)
    end

    describe 'with nil' do
      let(:error_message) { super() + 'nil' }

      it 'should raise an error' do
        expect { described_class.new(nil, adapter: adapter) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Object' do
      let(:object)        { Object.new }
      let(:error_message) { super() + object.inspect }

      it 'should raise an error' do
        expect { described_class.new(object, adapter: adapter) }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  describe '#adapter' do
    include_examples 'should have reader', :adapter, -> { adapter }
  end

  describe '#count' do
    it { expect(collection).to respond_to(:count).with(0).arguments }

    it 'should delegate to the query' do
      collection.count

      expect(query).to have_received(:count).with(no_args)
    end

    it { expect(collection.count).to be query.count }
  end

  describe '#delete_matching' do
    shared_context 'when the adapter result includes data' do
      let(:data) do
        [
          {
            'title'  => 'Romance of the Three Kingdoms',
            'author' => 'Luo Guanzhong'
          },
          {
            'title'  => 'Journey to the West',
            'author' => "Wu Cheng'en"
          },
          {
            'title'  => 'Dream of the Red Chamber',
            'author' => 'Cao Xueqin'
          }
        ]
      end
      let(:value) { { count: 3, data: data } }
    end

    shared_examples 'should delete the matching items' do
      describe 'with an empty Hash selector' do
        let(:selector) { {} }

        include_examples 'should delegate to the adapter'
      end

      describe 'with a non-empty Hash selector' do
        let(:selector) { { author: 'Luo Guanzhong' } }

        include_examples 'should delegate to the adapter'
      end
    end

    let(:method_name) { :delete_matching }
    let(:selector)    { nil }
    let(:value)       { { count: 3 } }
    let(:expected)    { value }
    let(:expected_keywords) do
      {
        collection_name: collection.name,
        selector:        selector
      }
    end

    def call_method
      collection.delete_matching(selector)
    end

    it { expect(collection).to respond_to(:delete_matching).with(1).arguments }

    include_examples 'should validate the selector'

    include_examples 'should delete the matching items'

    wrap_context 'when the adapter result includes data' do
      let(:transform) do
        Bronze::Transforms::Entities::NormalizeTransform.new(entity_class)
      end
      let(:transformed_data) do
        data.map { |item| transform.denormalize(item) }
      end
      let(:expected) { super().merge(data: transformed_data) }

      include_examples 'should delete the matching items'
    end

    wrap_context 'when initialized with a transform' do
      include_examples 'should delete the matching items'

      wrap_context 'when the adapter result includes data' do
        let(:transformed_data) do
          data.map { |item| transform.denormalize(item) }
        end
        let(:expected) { super().merge(data: transformed_data) }

        include_examples 'should delete the matching items'
      end
    end
  end

  describe '#delete_one' do
    shared_examples 'should delete the item' do
      describe 'with a valid primary key' do
        include_examples 'should delegate to the adapter'
      end
    end

    let(:method_name) { :delete_one }
    let(:value) do
      {
        'title'  => 'Romance of the Three Kingdoms',
        'author' => 'Luo Guanzhong'
      }
    end
    let(:expected) { entity_class.new(value) }
    let(:expected_keywords) do
      {
        collection_name:   collection.name,
        primary_key:       primary_key,
        primary_key_value: primary_key_value
      }
    end

    def call_method
      collection.delete_one(primary_key_value)
    end

    it { expect(collection).to respond_to(:delete_one).with(1).argument }

    it { expect(collection).to alias_method(:delete_one).as(:delete) }

    include_examples 'should validate the primary key for querying'

    wrap_context 'when the entity class has an integer primary key' do
      let(:value) do
        super().merge(primary_key.to_s => primary_key_value)
      end

      include_examples 'should delete the item'

      wrap_context 'when initialized with a transform' do
        let(:expected) { transform.denormalize(value) }

        include_examples 'should delete the item'
      end
    end

    wrap_context 'when the entity class has a string primary key' do
      let(:value) do
        super().merge(primary_key.to_s => primary_key_value)
      end

      include_examples 'should delete the item'

      wrap_context 'when initialized with a transform' do
        let(:expected) { transform.denormalize(value) }

        include_examples 'should delete the item'
      end
    end
  end

  describe '#each' do
    it { expect(collection).to respond_to(:each).with(0).arguments }

    it 'should delegate to the query' do
      collection.each

      expect(query).to have_received(:each).with(no_args)
    end

    it { expect(collection.each).to be query.each }
  end

  describe '#find_matching' do
    shared_examples 'should delegate to the adapter with options' do
      describe 'with no options' do
        include_examples 'should delegate to the adapter'
      end

      describe 'with limit: value' do
        let(:method_options) { super().merge limit: 3 }

        include_examples 'should delegate to the adapter'
      end

      describe 'with order: value' do
        let(:method_options) { super().merge order: :title }

        include_examples 'should delegate to the adapter'
      end

      describe 'with offset: value' do
        let(:method_options) { super().merge offset: 3 }

        include_examples 'should delegate to the adapter'
      end

      describe 'with multiple options' do
        let(:method_options) do
          super().merge limit: 4, offset: 2, order: :title
        end

        include_examples 'should delegate to the adapter'
      end
    end

    shared_examples 'should find the matching items' do
      describe 'with an empty Hash selector' do
        let(:selector) { {} }

        include_examples 'should delegate to the adapter with options'
      end

      describe 'with a non-empty Hash selector' do
        let(:selector) { { author: 'Luo Guanzhong' } }

        include_examples 'should delegate to the adapter with options'
      end
    end

    let(:transform_class) do
      Bronze::Transforms::Entities::NormalizeTransform
    end
    let(:method_name)    { :find_matching }
    let(:selector)       { nil }
    let(:method_options) { {} }
    let(:delegated_options) do
      {
        limit:  nil,
        offset: nil,
        order:  nil
      }.merge(method_options)
    end
    let(:value) do
      [
        {
          'title'    => 'Romance of the Three Kingdoms',
          'author'   => 'Luo Guanzhong',
          'language' => 'Chinese'
        }
      ]
    end
    let(:expected) { value }
    let(:expected_keywords) do
      {
        collection_name: collection.name,
        selector:        selector,
        transform:       an_instance_of(transform_class),
        **delegated_options
      }
    end

    def call_method
      collection.find_matching(selector, **method_options)
    end

    it 'should define the method' do
      expect(collection)
        .to respond_to(:find_matching)
        .with(1).argument
        .and_keywords(:limit, :offset, :order)
    end

    include_examples 'should validate the selector'

    include_examples 'should find the matching items'

    wrap_context 'when initialized with a transform' do
      let(:expected_keywords) do
        {
          collection_name: collection.name,
          selector:        selector,
          transform:       transform,
          **delegated_options
        }
      end

      include_examples 'should find the matching items'
    end
  end

  describe '#find_one' do
    shared_examples 'should find the item' do
      describe 'with a valid primary key' do
        include_examples 'should delegate to the adapter'
      end
    end

    let(:transform_class) do
      Bronze::Transforms::Entities::NormalizeTransform
    end
    let(:primary_key)       { :id }
    let(:primary_key_value) { 0 }
    let(:method_name)       { :find_one }
    let(:data) do
      {
        'id'     => 0,
        'title'  => 'Romance of the Three Kingdoms',
        'author' => 'Luo Guanzhong'
      }
    end
    let(:value)    { data }
    let(:expected) { value }
    let(:expected_keywords) do
      {
        collection_name:   collection.name,
        primary_key:       primary_key,
        primary_key_value: primary_key_value,
        transform:         an_instance_of(transform_class)
      }
    end

    def call_method
      collection.find_one(primary_key_value)
    end

    it { expect(collection).to respond_to(:find_one).with(1).argument }

    it { expect(collection).to alias_method(:find_one).as(:find) }

    include_examples 'should validate the primary key for querying'

    wrap_context 'when the entity class has an integer primary key' do
      include_examples 'should find the item'
    end

    wrap_context 'when the entity class has a string primary key' do
      include_examples 'should find the item'
    end
  end

  describe '#insert_one' do
    shared_examples 'should insert the item' do
      describe 'with a valid entity' do
        include_examples 'should delegate to the adapter'
      end
    end

    let(:data) do
      {
        'title'  => 'Romance of the Three Kingdoms',
        'author' => 'Luo Guanzhong'
      }
    end
    let(:object)      { entity_class.new(data) }
    let(:value)       { data }
    let(:expected)    { object }
    let(:method_name) { :insert_one }
    let(:expected_keywords) do
      {
        collection_name: collection.name,
        data:            data
      }
    end

    def call_method
      collection.insert_one(object)
    end

    it { expect(collection).to respond_to(:insert_one).with(1).argument }

    it { expect(collection).to alias_method(:insert_one).as(:insert) }

    include_examples 'should validate the primary key for insertion'

    include_examples 'should validate the data object for insertion'

    include_examples 'should insert the item'

    wrap_context 'when the entity class has an integer primary key' do
      describe 'with a nil primary key' do
        let(:expected_keywords) do
          super().tap do |hsh|
            hsh[:data][primary_key.to_s] = entity_class.primary_key.default
          end
        end

        include_examples 'should insert the item'
      end

      describe 'with a primary key value' do
        let(:data) do
          super().merge(primary_key.to_s => 13)
        end

        include_examples 'should insert the item'
      end
    end

    wrap_context 'when the entity class has a string primary key' do
      describe 'with a nil primary key' do
        let(:expected_keywords) do
          super().tap do |hsh|
            hsh[:data][primary_key.to_s] = entity_class.primary_key.default
          end
        end

        include_examples 'should insert the item'
      end

      describe 'with a primary key value' do
        let(:data) do
          super().merge(
            primary_key.to_s => '00000000-0000-0000-0000-00000000000d'
          )
        end

        include_examples 'should insert the item'
      end
    end
  end

  describe '#matching' do
    let(:selector) { { publisher: 'Amazing Stories' } }

    it { expect(collection).to respond_to(:matching).with(1).argument }

    it { expect(collection).to alias_method(:matching).as(:where) }

    it 'should delegate to the query' do
      collection.matching(selector)

      expect(query).to have_received(:matching).with(selector)
    end

    it { expect(collection.matching(selector)).to be subquery }
  end

  describe '#name' do
    before(:example) do
      allow(adapter)
        .to receive(:collection_name_for)
        .with(entity_class)
        .and_return('spec__coloring_books')
    end

    it { expect(collection.name).to be == 'spec__coloring_books' }

    context 'when options[:name] is set' do
      let(:options) { { name: 'madlibs' } }

      it { expect(collection.name).to be == 'madlibs' }
    end

    context 'when the entity class defines ::collection_name' do
      before(:example) do
        Spec::ColoringBook
          .singleton_class
          .send(:define_method, :collection_name) { 'coloring_books' }
      end

      it { expect(collection.name).to be == 'coloring_books' }

      context 'when options[:name] is set' do
        let(:options) { { name: 'madlibs' } }

        it { expect(collection.name).to be == 'madlibs' }
      end
    end
  end

  describe '#null_query' do
    it { expect(collection).to respond_to(:null_query).with(0).arguments }

    it { expect(collection).to alias_method(:null_query).as(:none) }

    it 'should delegate to the adapter' do
      collection.null_query

      expect(adapter)
        .to have_received(:null_query)
        .with(collection_name: collection.name)
    end

    it { expect(collection.null_query).to be null_query }
  end

  describe '#primary_key' do
    include_examples 'should have reader', :primary_key, nil

    wrap_context 'when the entity class has an integer primary key' do
      it { expect(collection.primary_key).to be == primary_key }
    end

    wrap_context 'when the entity class has a string primary key' do
      it { expect(collection.primary_key).to be == primary_key }
    end
  end

  describe '#primary_key?' do
    include_examples 'should have predicate', :primary_key?, false

    wrap_context 'when the entity class has an integer primary key' do
      it { expect(collection.primary_key?).to be true }
    end

    wrap_context 'when the entity class has a string primary key' do
      it { expect(collection.primary_key?).to be true }
    end
  end

  describe '#primary_key_type' do
    include_examples 'should have reader', :primary_key_type, nil

    wrap_context 'when the entity class has an integer primary key' do
      it { expect(collection.primary_key_type).to be == primary_key_type }
    end

    wrap_context 'when the entity class has a string primary key' do
      it { expect(collection.primary_key_type).to be == primary_key_type }
    end
  end

  describe '#query' do
    let(:transform_class) { Bronze::Transforms::Entities::NormalizeTransform }

    it { expect(collection).to respond_to(:query).with(0).arguments }

    it { expect(collection).to alias_method(:query).as(:all) }

    it 'should delegate to the adapter' do # rubocop:disable RSpec/ExampleLength
      collection.query

      expect(adapter)
        .to have_received(:query)
        .with(
          collection_name: collection.name,
          transform:       an_instance_of(transform_class)
        )
    end

    it { expect(collection.query).to be query }

    wrap_context 'when initialized with a transform' do
      it 'should delegate to the adapter' do
        collection.query

        expect(adapter)
          .to have_received(:query)
          .with(collection_name: collection.name, transform: transform)
      end
    end
  end

  describe '#transform' do
    let(:transform_class) { Bronze::Transforms::Entities::NormalizeTransform }

    include_examples 'should have reader', :transform

    it { expect(collection.transform).to be_a transform_class }

    it { expect(collection.transform.entity_class).to be definition }

    wrap_context 'when initialized with a transform' do
      it { expect(collection.transform).to be transform }
    end
  end

  describe '#update_matching' do
    shared_context 'when the adapter result includes data' do
      let(:result_data) do
        [
          {
            'title'  => 'Romance of the Three Kingdoms',
            'author' => 'Luo Guanzhong'
          },
          {
            'title'  => 'Journey to the West',
            'author' => "Wu Cheng'en"
          },
          {
            'title'  => 'Dream of the Red Chamber',
            'author' => 'Cao Xueqin'
          }
        ]
      end
      let(:value) { { count: 3, data: result_data } }
    end

    shared_examples 'should update the matching items' do
      describe 'with an empty data object' do
        let(:data) { {} }
        let(:expected_error) do
          Bronze::Errors.new.add(
            Bronze::Collections::Errors::DATA_EMPTY,
            data: object
          )
        end

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with a valid selector and data object with String keys' do
        let(:selector) { { author: 'Luo Guanzhong' } }
        let(:data)     { { 'language' => 'Chinese' } }

        include_examples 'should delegate to the adapter'
      end

      describe 'with a valid selector and data object with Symbol keys' do
        let(:selector) { { author: 'Luo Guanzhong' } }
        let(:data)     { { language: 'Chinese' } }

        include_examples 'should delegate to the adapter'
      end
    end

    let(:method_name) { :update_matching }
    let(:selector)    { { key: 'value' } }
    let(:data) do
      {
        'title'  => 'Romance of the Three Kingdoms',
        'author' => 'Luo Guanzhong'
      }
    end
    let(:object)      { data }
    let(:value)       { { count: 3 } }
    let(:expected)    { value }
    let(:expected_keywords) do
      {
        collection_name: collection.name,
        data:            data,
        selector:        selector
      }
    end

    def call_method
      collection.update_matching(selector, with: object)
    end

    it 'should define the method' do
      expect(collection).to respond_to(:update_matching)
        .with(1).arguments
        .with_keywords(:with)
    end

    include_examples 'should validate the data object'

    include_examples 'should validate the primary key for bulk updates'

    include_examples 'should validate the selector'

    include_examples 'should update the matching items'

    wrap_context 'when the adapter result includes data' do
      let(:transform) do
        Bronze::Transforms::Entities::NormalizeTransform.new(entity_class)
      end
      let(:transformed_data) do
        result_data.map { |item| transform.denormalize(item) }
      end
      let(:expected) { super().merge(data: transformed_data) }

      include_examples 'should update the matching items'
    end

    wrap_context 'when initialized with a transform' do
      include_examples 'should update the matching items'

      wrap_context 'when the adapter result includes data' do
        let(:transformed_data) do
          result_data.map { |item| transform.denormalize(item) }
        end
        let(:expected) { super().merge(data: transformed_data) }

        include_examples 'should update the matching items'
      end
    end
  end

  describe '#update_one' do
    shared_examples 'should update the item' do
      describe 'with an empty data object' do
        let(:data) { {} }
        let(:expected_error) do
          Bronze::Errors.new.add(
            Bronze::Collections::Errors::DATA_EMPTY,
            data: object
          )
        end

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with a valid primary key and data object with String keys' do
        let(:data)   { { 'language' => 'Chinese' } }

        include_examples 'should delegate to the adapter'
      end

      describe 'with a valid primary key and data object with Symbol keys' do
        let(:data)   { { language: 'Chinese' } }

        include_examples 'should delegate to the adapter'
      end
    end

    let(:method_name) { :update_one }
    let(:data)        { { language: 'Chinese' } }
    let(:object)      { data }
    let(:value) do
      {
        'title'  => 'Romance of the Three Kingdoms',
        'author' => 'Luo Guanzhong'
      }
    end
    let(:expected) { collection.transform.denormalize(value) }
    let(:expected_keywords) do
      {
        collection_name:   collection.name,
        data:              data,
        primary_key:       primary_key,
        primary_key_value: primary_key_value
      }
    end

    def call_method
      collection.update_one(primary_key_value, with: object)
    end

    it 'should define the method' do
      expect(collection).to respond_to(:update_one)
        .with(1).arguments
        .with_keywords(:with)
    end

    it { expect(collection).to alias_method(:update_one).as(:update) }

    include_examples 'should validate the primary key for querying'

    include_examples 'should validate the primary key for updates'

    wrap_context 'when the entity class has an integer primary key' do
      include_examples 'should validate the data object'

      include_examples 'should update the item'

      wrap_context 'when initialized with a transform' do
        let(:expected) { transform.denormalize(value) }

        include_examples 'should update the item'
      end
    end

    wrap_context 'when the entity class has a string primary key' do
      include_examples 'should validate the data object'

      include_examples 'should update the item'

      wrap_context 'when initialized with a transform' do
        let(:expected) { transform.denormalize(value) }

        include_examples 'should update the item'
      end
    end
  end
end
