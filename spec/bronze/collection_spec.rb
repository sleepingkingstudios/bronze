# frozen_string_literal: true

require 'bronze/collection'
require 'bronze/collections/adapter'
require 'bronze/collections/query'
require 'bronze/entities/primary_key'
require 'bronze/entity'

RSpec.describe Bronze::Collection do
  shared_context 'when the definition is an entity class' do
    let(:definition) { Spec::ColoringBook }

    example_class 'Spec::ColoringBook', Bronze::Entity
  end

  shared_context 'when the entity class has a primary key' do
    let(:primary_key)       { :id }
    let(:primary_key_type)  { Integer }
    let(:primary_key_value) { 0 }

    before(:example) do
      Spec::ColoringBook.send :include, Bronze::Entities::PrimaryKey

      Spec::ColoringBook.define_primary_key :id, Integer, default: -> { 0 }
    end
  end

  shared_context 'when the entity class has a custom primary key' do
    let(:primary_key)       { :hex }
    let(:primary_key_type)  { String }
    let(:primary_key_value) { 'ff' }

    before(:example) do
      Spec::ColoringBook.send :include, Bronze::Entities::PrimaryKey

      Spec::ColoringBook.define_primary_key :hex, String, default: -> { 'ff' }
    end
  end

  shared_examples 'should validate the data object' do
    describe 'with a nil data object' do
      let(:data) { nil }
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::DATA_MISSING,
          params: {}
        }
      end

      it 'should not delegate to the adapter' do
        call_operation

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a result' do
        expect(call_operation)
          .to be_a_failing_result
          .with_errors(expected_error)
      end
    end

    describe 'with a non-Hash data object' do
      let(:data) { Object.new }
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::DATA_INVALID,
          params: { data: data }
        }
      end

      it 'should not delegate to the adapter' do
        call_operation

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a result' do
        expect(call_operation)
          .to be_a_failing_result
          .with_errors(expected_error)
      end
    end

    describe 'with an empty data object' do
      let(:data) { {} }
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::DATA_EMPTY,
          params: { data: data }
        }
      end

      it 'should not delegate to the adapter' do
        call_operation

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a result' do
        expect(call_operation)
          .to be_a_failing_result
          .with_errors(expected_error)
      end
    end
  end

  shared_examples 'should validate the primary key for bulk updates' do
    describe 'with a data object that includes the primary key' do
      describe 'with String keys' do
        let(:data) { { primary_key.to_s => primary_key_value } }
        let(:expected_error) do
          {
            type:   Bronze::Collections::Errors::PRIMARY_KEY_BULK_UPDATE,
            params: { value: primary_key_value },
            path:   [primary_key]
          }
        end

        it 'should not delegate to the adapter' do
          call_operation

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a result' do
          expect(call_operation)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end

      describe 'with Symbol keys' do
        let(:data) { { primary_key => primary_key_value } }
        let(:expected_error) do
          {
            type:   Bronze::Collections::Errors::PRIMARY_KEY_BULK_UPDATE,
            params: { value: primary_key_value },
            path:   [primary_key]
          }
        end

        it 'should not delegate to the adapter' do
          call_operation

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a result' do
          expect(call_operation)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end
    end

    context 'when options[:primary_key] is false' do
      let(:options) { super().merge primary_key: false }

      describe 'with String keys' do
        let(:data) { { primary_key.to_s => primary_key_value } }

        it 'should delegate to the adapter' do
          call_operation

          expect(adapter).to have_received(method_name)
        end

        it 'should return a passing result' do
          expect(call_operation).to be_a_passing_result
        end
      end

      describe 'with Symbol keys' do
        let(:data) { { primary_key => primary_key_value } }

        it 'should delegate to the adapter' do
          call_operation

          expect(adapter).to have_received(method_name)
        end

        it 'should return a passing result' do
          expect(call_operation).to be_a_passing_result
        end
      end
    end

    context 'when options[:primary_key] is set' do
      let(:primary_key)       { :uuid }
      let(:primary_key_type)  { String }
      let(:primary_key_value) { '' }
      let(:options) do
        super().merge primary_key: :uuid, primary_key_type: String
      end

      describe 'with a data object that includes the primary key' do
        describe 'with String keys' do
          let(:data) { { primary_key.to_s => primary_key_value } }
          let(:expected_error) do
            {
              type:   Bronze::Collections::Errors::PRIMARY_KEY_BULK_UPDATE,
              params: { value: primary_key_value },
              path:   [primary_key]
            }
          end

          it 'should not delegate to the adapter' do
            call_operation

            expect(adapter).not_to have_received(method_name)
          end

          it 'should return a result' do
            expect(call_operation)
              .to be_a_failing_result
              .with_errors(expected_error)
          end
        end

        describe 'with Symbol keys' do
          let(:data) { { primary_key => primary_key_value } }
          let(:expected_error) do
            {
              type:   Bronze::Collections::Errors::PRIMARY_KEY_BULK_UPDATE,
              params: { value: primary_key_value },
              path:   [primary_key]
            }
          end

          it 'should not delegate to the adapter' do
            call_operation

            expect(adapter).not_to have_received(method_name)
          end

          it 'should return a result' do
            expect(call_operation)
              .to be_a_failing_result
              .with_errors(expected_error)
          end
        end
      end
    end
  end

  shared_examples 'should validate the primary key for insertion' do
    describe 'with a nil primary key' do
      let(:data) { super().tap { |hsh| hsh.delete primary_key.to_s } }
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::PRIMARY_KEY_MISSING,
          params: {},
          path:   [primary_key]
        }
      end

      it 'should not delegate to the adapter' do
        call_operation

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a result' do
        expect(call_operation)
          .to be_a_failing_result
          .with_errors(expected_error)
      end
    end

    describe 'with a primary key with invalid type' do
      let(:primary_key_value) { Object.new }
      let(:data) do
        super().merge(primary_key => primary_key_value)
      end
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::PRIMARY_KEY_INVALID,
          params: {
            type:  primary_key_type.name,
            value: primary_key_value.to_s
          },
          path:   [primary_key]
        }
      end

      it 'should not delegate to the adapter' do
        call_operation

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a result' do
        expect(call_operation)
          .to be_a_failing_result
          .with_errors(expected_error)
      end
    end

    describe 'with an empty primary key' do
      let(:primary_key_type)  { String }
      let(:primary_key_value) { '' }
      let(:data) do
        super().merge(primary_key => primary_key_value)
      end
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::PRIMARY_KEY_EMPTY,
          params: { value: primary_key_value.to_s },
          path:   [primary_key]
        }
      end

      it 'should not delegate to the adapter' do
        call_operation

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a result' do
        expect(call_operation)
          .to be_a_failing_result
          .with_errors(expected_error)
      end
    end

    context 'when options[:primary_key] is false' do
      let(:options) { super().merge primary_key: false }

      describe 'with a nil primary key' do
        let(:data) { super().tap { |hsh| hsh.delete primary_key.to_s } }

        it 'should delegate to the adapter' do
          call_operation

          expect(adapter).to have_received(method_name)
        end

        it 'should return a passing result' do
          expect(call_operation).to be_a_passing_result
        end
      end

      describe 'with a primary key with invalid type' do
        let(:primary_key_value) { Object.new }
        let(:data) do
          super().merge(primary_key => primary_key_value)
        end

        it 'should delegate to the adapter' do
          call_operation

          expect(adapter).to have_received(method_name)
        end

        it 'should return a passing result' do
          expect(call_operation).to be_a_passing_result
        end
      end

      describe 'with an empty primary key' do
        let(:primary_key_type)  { String }
        let(:primary_key_value) { '' }
        let(:data) do
          super().merge(primary_key => primary_key_value)
        end

        it 'should delegate to the adapter' do
          call_operation

          expect(adapter).to have_received(method_name)
        end

        it 'should return a passing result' do
          expect(call_operation).to be_a_passing_result
        end
      end
    end

    context 'when options[:primary_key] is set' do
      let(:primary_key)       { :uuid }
      let(:primary_key_type)  { String }
      let(:primary_key_value) { '' }
      let(:options) do
        super().merge primary_key: :uuid, primary_key_type: String
      end

      describe 'with a nil primary key' do
        let(:data) { super().tap { |hsh| hsh.delete primary_key.to_s } }
        let(:expected_error) do
          {
            type:   Bronze::Collections::Errors::PRIMARY_KEY_MISSING,
            params: {},
            path:   [primary_key]
          }
        end

        it 'should not delegate to the adapter' do
          call_operation

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a result' do
          expect(call_operation)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end

      describe 'with a primary key with invalid type' do
        let(:primary_key_value) { Object.new }
        let(:data) do
          super().merge(primary_key => primary_key_value)
        end
        let(:expected_error) do
          {
            type:   Bronze::Collections::Errors::PRIMARY_KEY_INVALID,
            params: {
              type:  primary_key_type.name,
              value: primary_key_value.to_s
            },
            path:   [primary_key]
          }
        end

        it 'should not delegate to the adapter' do
          call_operation

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a result' do
          expect(call_operation)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end

      describe 'with an empty primary key' do
        let(:data) do
          super().merge(primary_key => primary_key_value)
        end
        let(:expected_error) do
          {
            type:   Bronze::Collections::Errors::PRIMARY_KEY_EMPTY,
            params: { value: primary_key_value.to_s },
            path:   [primary_key]
          }
        end

        it 'should not delegate to the adapter' do
          call_operation

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a result' do
          expect(call_operation)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end
    end
  end

  shared_examples 'should validate the primary key for querying' do
    describe 'with a nil primary key' do
      let(:primary_key_value) { nil }
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::PRIMARY_KEY_MISSING,
          params: {},
          path:   [primary_key]
        }
      end

      it 'should not delegate to the adapter' do
        call_operation

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a result' do
        expect(call_operation)
          .to be_a_failing_result
          .with_errors(expected_error)
      end
    end

    describe 'with a primary key with invalid type' do
      let(:primary_key_value) { Object.new }
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::PRIMARY_KEY_INVALID,
          params: {
            type:  primary_key_type.name,
            value: primary_key_value.to_s
          },
          path:   [primary_key]
        }
      end

      it 'should not delegate to the adapter' do
        call_operation

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a result' do
        expect(call_operation)
          .to be_a_failing_result
          .with_errors(expected_error)
      end
    end

    describe 'with an empty primary key' do
      let(:primary_key_type)  { String }
      let(:primary_key_value) { '' }
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::PRIMARY_KEY_EMPTY,
          params: { value: primary_key_value.to_s },
          path:   [primary_key]
        }
      end

      it 'should not delegate to the adapter' do
        call_operation

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a result' do
        expect(call_operation)
          .to be_a_failing_result
          .with_errors(expected_error)
      end
    end

    context 'when options[:primary_key] is false' do
      let(:options) { super().merge primary_key: false }

      describe 'with a nil primary key' do
        let(:primary_key_value) { nil }
        let(:expected_error)    { Bronze::Collections::Errors::NO_PRIMARY_KEY }

        it 'should not delegate to the adapter' do
          call_operation

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a result' do
          expect(call_operation)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end

      describe 'with a primary key with invalid type' do
        let(:primary_key_value) { Object.new }
        let(:expected_error)    { Bronze::Collections::Errors::NO_PRIMARY_KEY }

        it 'should not delegate to the adapter' do
          call_operation

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a result' do
          expect(call_operation)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end

      describe 'with an empty primary key' do
        let(:primary_key_type)  { String }
        let(:primary_key_value) { '' }
        let(:expected_error)    { Bronze::Collections::Errors::NO_PRIMARY_KEY }

        it 'should not delegate to the adapter' do
          call_operation

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a result' do
          expect(call_operation)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end

      describe 'with a valid primary key' do
        let(:expected_error)    { Bronze::Collections::Errors::NO_PRIMARY_KEY }

        it 'should not delegate to the adapter' do
          call_operation

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a result' do
          expect(call_operation)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end
    end

    context 'when options[:primary_key] is set' do
      let(:primary_key)       { :uuid }
      let(:primary_key_type)  { String }
      let(:primary_key_value) { '' }
      let(:options) do
        super().merge primary_key: :uuid, primary_key_type: String
      end

      describe 'with a nil primary key' do
        let(:primary_key_value) { nil }
        let(:expected_error) do
          {
            type:   Bronze::Collections::Errors::PRIMARY_KEY_MISSING,
            params: {},
            path:   [primary_key]
          }
        end

        it 'should not delegate to the adapter' do
          call_operation

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a result' do
          expect(call_operation)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end

      describe 'with a primary key with invalid type' do
        let(:primary_key_value) { Object.new }
        let(:expected_error) do
          {
            type:   Bronze::Collections::Errors::PRIMARY_KEY_INVALID,
            params: {
              type:  primary_key_type.name,
              value: primary_key_value.to_s
            },
            path:   [primary_key]
          }
        end

        it 'should not delegate to the adapter' do
          call_operation

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a result' do
          expect(call_operation)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end

      describe 'with an empty primary key' do
        let(:primary_key_value) { '' }
        let(:expected_error) do
          {
            type:   Bronze::Collections::Errors::PRIMARY_KEY_EMPTY,
            params: { value: primary_key_value.to_s },
            path:   [primary_key]
          }
        end

        it 'should not delegate to the adapter' do
          call_operation

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a result' do
          expect(call_operation)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end
    end
  end

  shared_examples 'should validate the primary key for updates' do
    describe 'with primary_key: nil' do
      let(:data) { super().merge(primary_key => nil) }
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::PRIMARY_KEY_CHANGED,
          params: { value: nil },
          path:   [primary_key]
        }
      end

      it 'should not delegate to the adapter' do
        call_operation

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a result' do
        expect(call_operation)
          .to be_a_failing_result
          .with_errors(expected_error)
      end
    end

    describe 'with primary_key: different value' do
      let(:data) { super().merge(primary_key => 13) }
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::PRIMARY_KEY_CHANGED,
          params: { value: 13 },
          path:   [primary_key]
        }
      end

      it 'should not delegate to the adapter' do
        call_operation

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a result' do
        expect(call_operation)
          .to be_a_failing_result
          .with_errors(expected_error)
      end
    end

    describe 'with primary_key: same value' do
      let(:data) { super().merge(primary_key => primary_key_value) }

      it 'should delegate to the adapter' do
        call_operation

        expect(adapter).to have_received(method_name)
      end

      it 'should return a passing result' do
        expect(call_operation).to be_a_passing_result
      end
    end

    context 'when options[:primary_key] is false' do
      let(:options) { super().merge primary_key: false }

      describe 'with primary_key: nil' do
        let(:data) { super().merge(primary_key => nil) }
        let(:expected_error) do
          {
            type:   Bronze::Collections::Errors::NO_PRIMARY_KEY,
            params: {}
          }
        end

        it 'should not delegate to the adapter' do
          call_operation

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a result' do
          expect(call_operation)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end

      describe 'with primary_key: different value' do
        let(:data) { super().merge(primary_key => 13) }
        let(:expected_error) do
          {
            type:   Bronze::Collections::Errors::NO_PRIMARY_KEY,
            params: {}
          }
        end

        it 'should not delegate to the adapter' do
          call_operation

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a result' do
          expect(call_operation)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end

      describe 'with primary_key: same value' do
        let(:data) { super().merge(primary_key => primary_key_value) }
        let(:expected_error) do
          {
            type:   Bronze::Collections::Errors::NO_PRIMARY_KEY,
            params: {}
          }
        end

        it 'should not delegate to the adapter' do
          call_operation

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a result' do
          expect(call_operation)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end
    end

    context 'when options[:primary_key] is set' do
      let(:primary_key)       { :uuid }
      let(:primary_key_type)  { String }
      let(:primary_key_value) { '00000000-0000-0000-0000-000000000000' }
      let(:options) do
        super().merge primary_key: :uuid, primary_key_type: String
      end

      describe 'with primary_key: nil' do
        let(:data) { super().merge(primary_key => nil) }
        let(:expected_error) do
          {
            type:   Bronze::Collections::Errors::PRIMARY_KEY_CHANGED,
            params: { value: nil },
            path:   [primary_key]
          }
        end

        it 'should not delegate to the adapter' do
          call_operation

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a result' do
          expect(call_operation)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end

      describe 'with primary_key: different value' do
        let(:data) { super().merge(primary_key => 13) }
        let(:expected_error) do
          {
            type:   Bronze::Collections::Errors::PRIMARY_KEY_CHANGED,
            params: { value: 13 },
            path:   [primary_key]
          }
        end

        it 'should not delegate to the adapter' do
          call_operation

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a result' do
          expect(call_operation)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end

      describe 'with primary_key: same value' do
        let(:data) { super().merge(primary_key => primary_key_value) }

        it 'should delegate to the adapter' do
          call_operation

          expect(adapter).to have_received(method_name)
        end

        it 'should return a passing result' do
          expect(call_operation).to be_a_passing_result
        end
      end
    end
  end

  shared_examples 'should validate the selector' do
    describe 'with a nil selector' do
      let(:selector) { nil }
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::SELECTOR_MISSING,
          params: {}
        }
      end

      it 'should not delegate to the adapter' do
        call_operation

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a result' do
        expect(call_operation)
          .to be_a_failing_result
          .with_errors(expected_error)
      end
    end

    describe 'with a non-Hash selector' do
      let(:selector) { Object.new }
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::SELECTOR_INVALID,
          params: { selector: selector }
        }
      end

      it 'should not delegate to the adapter' do
        call_operation

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a result' do
        expect(call_operation)
          .to be_a_failing_result
          .with_errors(expected_error)
      end
    end
  end

  subject(:collection) do
    described_class.new(definition, adapter: adapter, **options)
  end

  let(:options)    { {} }
  let(:definition) { 'books' }
  let(:adapter) do
    instance_double(
      Bronze::Collections::Adapter,
      collection_name_for: '',
      delete_matching:     Bronze::Result.new,
      delete_one:          Bronze::Result.new,
      find_one:            Bronze::Result.new,
      insert_one:          Bronze::Result.new,
      query:               query,
      update_matching:     Bronze::Result.new,
      update_one:          Bronze::Result.new
    )
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

  def tools
    SleepingKingStudios::Tools::Toolbelt.instance
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(1).argument
        .and_keywords(:adapter, :name, :primary_key, :primary_key_type)
    end

    describe 'with nil' do
      let(:error_message) do
        'expected definition to be a collection name or a class, but was nil'
      end

      it 'should raise an error' do
        expect { described_class.new(nil, adapter: adapter) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Object' do
      let(:object) { Object.new }
      let(:error_message) do
        'expected definition to be a collection name or a class, but was ' \
        "#{object.inspect}"
      end

      it 'should raise an error' do
        expect { described_class.new(object, adapter: adapter) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an invalid :primary_key option' do
      let(:primary_key) { Object.new }
      let(:options) do
        {
          adapter:     adapter,
          primary_key: primary_key
        }
      end
      let(:error_message) do
        'expected primary key to be a String, a Symbol or false, but was ' \
        "#{primary_key.inspect}"
      end

      it 'should raise an error' do
        expect { described_class.new('books', **options) }
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
    let(:method_name) { :delete_matching }
    let(:selector)    { nil }

    def call_operation
      collection.delete_matching(selector)
    end

    it { expect(collection).to respond_to(:delete_matching).with(1).arguments }

    include_examples 'should validate the selector'

    describe 'with an empty Hash selector' do
      let(:selector) { {} }
      let(:expected) do
        {
          'title'    => 'Romance of the Three Kingdoms',
          'author'   => 'Luo Guanzhong',
          'language' => 'Chinese'
        }
      end
      let(:result) { Bronze::Result.new(expected) }

      it 'should delegate to the adapter' do
        collection.delete_matching(selector)

        expect(adapter)
          .to have_received(:delete_matching)
          .with(collection.name, selector)
      end

      it 'should return the result from the adapter' do
        allow(adapter).to receive(:delete_matching).and_return(result)

        expect(collection.delete_matching(selector)).to be result
      end
    end

    describe 'with a non-empty Hash selector' do
      let(:selector) { { author: 'Luo Guanzhong' } }
      let(:expected) do
        {
          'title'    => 'Romance of the Three Kingdoms',
          'author'   => 'Luo Guanzhong',
          'language' => 'Chinese'
        }
      end
      let(:result) { Bronze::Result.new(expected) }

      it 'should delegate to the adapter' do
        collection.delete_matching(selector)

        expect(adapter)
          .to have_received(:delete_matching)
          .with(collection.name, selector)
      end

      it 'should return the result from the adapter' do
        allow(adapter).to receive(:delete_matching).and_return(result)

        expect(collection.delete_matching(selector)).to be result
      end
    end
  end

  describe '#delete_one' do
    let(:primary_key)       { :id }
    let(:primary_key_type)  { Integer }
    let(:primary_key_value) { 0 }
    let(:method_name)       { :delete_one }
    let(:data) do
      {
        'id'     => 0,
        'title'  => 'Romance of the Three Kingdoms',
        'author' => 'Luo Guanzhong'
      }
    end
    let(:options) { super().merge primary_key_type: primary_key_type }

    def call_operation
      collection.delete_one(primary_key_value)
    end

    it { expect(collection).to respond_to(:delete_one).with(1).argument }

    it { expect(collection).to alias_method(:delete_one).as(:delete) }

    include_examples 'should validate the primary key for querying'

    describe 'with a valid primary key' do
      let(:result) { Bronze::Result.new(data) }

      it 'should delegate to the adapter' do
        collection.delete_one(primary_key_value)

        expect(adapter)
          .to have_received(:delete_one)
          .with(collection.name, primary_key, primary_key_value)
      end

      it 'should return the result from the adapter' do
        allow(adapter).to receive(:delete_one).and_return(result)

        expect(collection.delete_one(primary_key_value)).to be result
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

  describe '#find_one' do
    let(:primary_key)       { :id }
    let(:primary_key_type)  { Integer }
    let(:primary_key_value) { 0 }
    let(:method_name)       { :find_one }
    let(:data) do
      {
        'id'     => 0,
        'title'  => 'Romance of the Three Kingdoms',
        'author' => 'Luo Guanzhong'
      }
    end
    let(:options) { super().merge primary_key_type: primary_key_type }

    def call_operation
      collection.find_one(primary_key_value)
    end

    it { expect(collection).to respond_to(:find_one).with(1).argument }

    it { expect(collection).to alias_method(:find_one).as(:find) }

    include_examples 'should validate the primary key for querying'

    describe 'with a valid primary key' do
      let(:result) { Bronze::Result.new(data) }

      it 'should delegate to the adapter' do
        collection.find_one(primary_key_value)

        expect(adapter)
          .to have_received(:find_one)
          .with(collection.name, primary_key, primary_key_value)
      end

      it 'should return the result from the adapter' do
        allow(adapter).to receive(:find_one).and_return(result)

        expect(collection.find_one(primary_key_value)).to be result
      end
    end
  end

  describe '#insert_one' do
    let(:primary_key)       { :id }
    let(:primary_key_type)  { Integer }
    let(:primary_key_value) { 0 }
    let(:method_name)       { :insert_one }
    let(:data) do
      {
        'id'     => 0,
        'title'  => 'Romance of the Three Kingdoms',
        'author' => 'Luo Guanzhong'
      }
    end
    let(:options) { super().merge primary_key_type: primary_key_type }

    def call_operation
      collection.insert_one(data)
    end

    it { expect(collection).to respond_to(:insert_one).with(1).argument }

    it { expect(collection).to alias_method(:insert_one).as(:insert) }

    include_examples 'should validate the data object'

    include_examples 'should validate the primary key for insertion'

    describe 'with a valid data object with String keys' do
      let(:result) { Bronze::Result.new(data) }

      it 'should delegate to the adapter' do
        collection.insert_one(data)

        expect(adapter)
          .to have_received(:insert_one)
          .with(collection.name, data)
      end

      it 'should return the result from the adapter' do
        allow(adapter).to receive(:insert_one).and_return(result)

        expect(collection.insert_one(data)).to be result
      end
    end

    describe 'with a valid data object with Symbol keys' do
      let(:data) do
        tools.hash.convert_keys_to_symbols(super())
      end
      let(:result) do
        Bronze::Result.new.tap { |obj| obj.value = data }
      end

      it 'should delegate to the adapter' do
        collection.insert_one(data)

        expect(adapter)
          .to have_received(:insert_one)
          .with(collection.name, data)
      end

      it 'should return the result from the adapter' do
        allow(adapter).to receive(:insert_one).and_return(result)

        expect(collection.insert_one(data)).to be result
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
    include_examples 'should have reader',
      :name,
      -> { be == definition }

    context 'when the definition is a symbol' do
      let(:definition) { :periodicals }

      it { expect(collection.name).to be == 'periodicals' }

      context 'when options[:name] is set' do
        let(:options) { { name: 'magazines' } }

        it { expect(collection.name).to be == 'magazines' }
      end
    end

    context 'when the definition is a Module' do
      let(:definition) { Spec::ArchivedPeriodical }

      example_class 'Spec::ArchivedPeriodical'

      before(:example) do
        allow(adapter)
          .to receive(:collection_name_for)
          .with(definition)
          .and_return('spec__archived_periodicals')
      end

      it { expect(collection.name).to be == 'spec__archived_periodicals' }

      context 'when options[:name] is set' do
        let(:options) { { name: 'magazines' } }

        it { expect(collection.name).to be == 'magazines' }
      end
    end

    context 'when the definition is a Module that defines ::collection_name' do
      let(:definition) { Spec::TranslatedBook }

      example_class 'Spec::TranslatedBook' do |klass|
        klass.singleton_class.send(:define_method, :collection_name) do
          'translated_books'
        end
      end

      it { expect(collection.name).to be == 'translated_books' }

      context 'when options[:name] is set' do
        let(:options) { { name: 'books' } }

        it { expect(collection.name).to be == 'books' }
      end
    end

    wrap_context 'when the definition is an entity class' do
      before(:example) do
        allow(adapter)
          .to receive(:collection_name_for)
          .with(definition)
          .and_return('spec__coloring_books')
      end

      it { expect(collection.name).to be == 'spec__coloring_books' }

      context 'when options[:name] is set' do
        let(:options) { { name: 'magazines' } }

        it { expect(collection.name).to be == 'magazines' }
      end
    end
  end

  describe '#primary_key' do
    include_examples 'should have reader', :primary_key, :id

    context 'when options[:primary_key] is false' do
      let(:options) { super().merge primary_key: false }

      it { expect(collection.primary_key).to be false }
    end

    context 'when options[:primary_key] is a String' do
      let(:options) { super().merge primary_key: 'uuid' }

      it { expect(collection.primary_key).to be :uuid }
    end

    context 'when options[:primary_key] is a Symbol' do
      let(:options) { super().merge primary_key: :uuid }

      it { expect(collection.primary_key).to be :uuid }
    end

    wrap_context 'when the definition is an entity class' do
      it { expect(collection.primary_key).to be :id }

      context 'when options[:primary_key] is false' do
        let(:options) { super().merge primary_key: false }

        it { expect(collection.primary_key).to be false }
      end

      context 'when options[:primary_key] is set' do
        let(:options) { super().merge primary_key: 'uuid' }

        it { expect(collection.primary_key).to be :uuid }
      end

      wrap_context 'when the entity class has a primary key' do
        it { expect(collection.primary_key).to be :id }

        context 'when options[:primary_key] is false' do
          let(:options) { super().merge primary_key: false }

          it { expect(collection.primary_key).to be false }
        end

        context 'when options[:primary_key] is set' do
          let(:options) { super().merge primary_key: 'uuid' }

          it { expect(collection.primary_key).to be :uuid }
        end
      end

      wrap_context 'when the entity class has a custom primary key' do
        it { expect(collection.primary_key).to be :hex }

        context 'when options[:primary_key] is false' do
          let(:options) { super().merge primary_key: false }

          it { expect(collection.primary_key).to be false }
        end

        context 'when options[:primary_key] is set' do
          let(:options) { super().merge primary_key: 'uuid' }

          it { expect(collection.primary_key).to be :uuid }
        end
      end
    end
  end

  describe '#primary_key?' do
    include_examples 'should have predicate', :primary_key?, true

    context 'when options[:primary_key] is false' do
      let(:options) { super().merge primary_key: false }

      it { expect(collection.primary_key?).to be false }
    end

    context 'when options[:primary_key] is set' do
      let(:options) { super().merge primary_key: 'uuid' }

      it { expect(collection.primary_key?).to be true }
    end

    wrap_context 'when the definition is an entity class' do
      it { expect(collection.primary_key?).to be true }

      context 'when options[:primary_key] is false' do
        let(:options) { super().merge primary_key: false }

        it { expect(collection.primary_key?).to be false }
      end

      context 'when options[:primary_key] is set' do
        let(:options) { super().merge primary_key: 'uuid' }

        it { expect(collection.primary_key?).to be true }
      end

      wrap_context 'when the entity class has a primary key' do
        it { expect(collection.primary_key?).to be true }

        context 'when options[:primary_key] is false' do
          let(:options) { super().merge primary_key: false }

          it { expect(collection.primary_key?).to be false }
        end

        context 'when options[:primary_key] is set' do
          let(:options) { super().merge primary_key: 'uuid' }

          it { expect(collection.primary_key?).to be true }
        end
      end

      wrap_context 'when the entity class has a custom primary key' do
        it { expect(collection.primary_key?).to be true }

        context 'when options[:primary_key] is false' do
          let(:options) { super().merge primary_key: false }

          it { expect(collection.primary_key?).to be false }
        end

        context 'when options[:primary_key] is set' do
          let(:options) { super().merge primary_key: 'uuid' }

          it { expect(collection.primary_key?).to be true }
        end
      end
    end
  end

  describe '#primary_key_type' do
    include_examples 'should have reader', :primary_key_type, String

    context 'when options[:primary_key] is a Class' do
      let(:options) { super().merge primary_key_type: Symbol }

      it { expect(collection.primary_key_type).to be Symbol }
    end

    context 'when options[:primary_key] is a class name' do
      let(:options) { super().merge primary_key_type: 'Symbol' }

      it { expect(collection.primary_key_type).to be Symbol }
    end

    wrap_context 'when the definition is an entity class' do
      it { expect(collection.primary_key_type).to be String }

      context 'when options[:primary_key] is a Class' do
        let(:options) { super().merge primary_key_type: Symbol }

        it { expect(collection.primary_key_type).to be Symbol }
      end

      context 'when options[:primary_key] is a class name' do
        let(:options) { super().merge primary_key_type: 'Symbol' }

        it { expect(collection.primary_key_type).to be Symbol }
      end

      wrap_context 'when the entity class has a primary key' do
        it { expect(collection.primary_key_type).to be Integer }

        context 'when options[:primary_key] is a Class' do
          let(:options) { super().merge primary_key_type: Symbol }

          it { expect(collection.primary_key_type).to be Symbol }
        end

        context 'when options[:primary_key] is a class name' do
          let(:options) { super().merge primary_key_type: 'Symbol' }

          it { expect(collection.primary_key_type).to be Symbol }
        end
      end

      wrap_context 'when the entity class has a custom primary key' do
        it { expect(collection.primary_key_type).to be String }

        context 'when options[:primary_key] is a Class' do
          let(:options) { super().merge primary_key_type: Symbol }

          it { expect(collection.primary_key_type).to be Symbol }
        end

        context 'when options[:primary_key] is a class name' do
          let(:options) { super().merge primary_key_type: 'Symbol' }

          it { expect(collection.primary_key_type).to be Symbol }
        end
      end
    end
  end

  describe '#query' do
    it { expect(collection).to respond_to(:query).with(0).arguments }

    it { expect(collection).to alias_method(:query).as(:all) }

    it 'should delegate to the adapter' do
      collection.query

      expect(adapter).to have_received(:query).with(collection.name)
    end

    it { expect(collection.query).to be query }
  end

  describe '#update_matching' do
    let(:primary_key)       { :id }
    let(:primary_key_type)  { Integer }
    let(:primary_key_value) { 0 }
    let(:method_name)       { :update_matching }
    let(:selector)          { { key: 'value' } }
    let(:data)              { nil }

    def call_operation
      collection.update_matching(selector, with: data)
    end

    it 'should define the method' do
      expect(collection).to respond_to(:update_matching)
        .with(1).arguments
        .with_keywords(:with)
    end

    include_examples 'should validate the data object'

    include_examples 'should validate the primary key for bulk updates'

    include_examples 'should validate the selector'

    describe 'with a valid selector and data object with String keys' do
      let(:selector) { { author: 'Luo Guanzhong' } }
      let(:data)     { { 'language' => 'Chinese' } }
      let(:expected) do
        {
          'title'    => 'Romance of the Three Kingdoms',
          'author'   => 'Luo Guanzhong',
          'language' => 'Chinese'
        }
      end
      let(:result) { Bronze::Result.new(expected) }

      it 'should delegate to the adapter' do
        collection.update_matching(selector, with: data)

        expect(adapter)
          .to have_received(:update_matching)
          .with(collection.name, selector, data)
      end

      it 'should return the result from the adapter' do
        allow(adapter).to receive(:update_matching).and_return(result)

        expect(collection.update_matching(selector, with: data)).to be result
      end
    end

    describe 'with a valid selector and data object with Symbol keys' do
      let(:selector) { { author: 'Luo Guanzhong' } }
      let(:data)     { { language: 'Chinese' } }
      let(:expected) do
        {
          'title'    => 'Romance of the Three Kingdoms',
          'author'   => 'Luo Guanzhong',
          'language' => 'Chinese'
        }
      end
      let(:result) { Bronze::Result.new(expected) }

      it 'should delegate to the adapter' do
        collection.update_matching(selector, with: data)

        expect(adapter)
          .to have_received(:update_matching)
          .with(collection.name, selector, data)
      end

      it 'should return the result from the adapter' do
        allow(adapter).to receive(:update_matching).and_return(result)

        expect(collection.update_matching(selector, with: data)).to be result
      end
    end
  end

  describe '#update_one' do
    let(:primary_key)       { :id }
    let(:primary_key_type)  { Integer }
    let(:primary_key_value) { 0 }
    let(:method_name)       { :update_one }
    let(:data)              { { language: 'Chinese' } }
    let(:options) do
      super().merge primary_key_type: primary_key_type
    end

    def call_operation
      collection.update_one(primary_key_value, with: data)
    end

    it 'should define the method' do
      expect(collection).to respond_to(:update_one)
        .with(1).arguments
        .with_keywords(:with)
    end

    it { expect(collection).to alias_method(:update_one).as(:update) }

    include_examples 'should validate the data object'

    include_examples 'should validate the primary key for querying'

    include_examples 'should validate the primary key for updates'

    describe 'with a valid primary key and data object with String keys' do
      let(:data) { { 'language' => 'Chinese' } }
      let(:expected) do
        {
          'title'    => 'Romance of the Three Kingdoms',
          'author'   => 'Luo Guanzhong',
          'language' => 'Chinese'
        }
      end
      let(:result) { Bronze::Result.new(expected) }

      it 'should delegate to the adapter' do
        collection.update_one(primary_key_value, with: data)

        expect(adapter)
          .to have_received(:update_one)
          .with(collection.name, primary_key, primary_key_value, data)
      end

      it 'should return the result from the adapter' do
        allow(adapter).to receive(:update_one).and_return(result)

        expect(collection.update_one(primary_key_value, with: data))
          .to be result
      end
    end

    describe 'with a valid primary key and data object with Symbol keys' do
      let(:data) { { language: 'Chinese' } }
      let(:expected) do
        {
          'title'    => 'Romance of the Three Kingdoms',
          'author'   => 'Luo Guanzhong',
          'language' => 'Chinese'
        }
      end
      let(:result) { Bronze::Result.new(expected) }

      it 'should delegate to the adapter' do
        collection.update_one(primary_key_value, with: data)

        expect(adapter)
          .to have_received(:update_one)
          .with(collection.name, primary_key, primary_key_value, data)
      end

      it 'should return the result from the adapter' do
        allow(adapter).to receive(:update_one).and_return(result)

        expect(collection.update_one(primary_key_value, with: data))
          .to be result
      end
    end
  end
end
