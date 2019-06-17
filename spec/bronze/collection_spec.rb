# frozen_string_literal: true

require 'bronze/collection'
require 'bronze/collections/adapter'
require 'bronze/collections/null_query'
require 'bronze/collections/query'
require 'bronze/entities/primary_key'
require 'bronze/entities/primary_keys/uuid'
require 'bronze/entity'
require 'bronze/transforms/identity_transform'
require 'bronze/transforms/entities/normalize_transform'

require 'support/entities/examples/basic_book'
require 'support/transforms/capitalize_keys_transform'

RSpec.describe Bronze::Collection do
  shared_context 'when the definition is an entity class' do
    let(:definition)       { Spec::BasicBook }
    let(:primary_key)      { definition.primary_key.name }
    let(:primary_key_type) { definition.primary_key.type }
  end

  shared_context 'when initialized with a transform' do
    let(:transform) { Spec::CapitalizeKeysTransform.new }
    let(:options)   { super().merge(transform: transform) }
  end

  shared_context 'when initialized with an entity transform' do
    let(:transform) do
      Bronze::Transforms::Entities::NormalizeTransform.new(definition)
    end
    let(:options) { super().merge(transform: transform) }
  end

  shared_examples 'should validate the data object' do
    describe 'with a nil data object' do
      let(:object) { nil }
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::DATA_MISSING,
          params: {}
        }
      end

      it 'should not delegate to the adapter' do
        call_method

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a failing result' do
        expect(call_method)
          .to be_a_failing_result
          .with_errors(expected_error)
      end
    end

    describe 'with a non-Hash data object' do
      let(:object) { Object.new }
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::DATA_INVALID,
          params: { data: object }
        }
      end

      it 'should not delegate to the adapter' do
        call_method

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a failing result' do
        expect(call_method)
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
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
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
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
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
          call_method

          expect(adapter).to have_received(method_name)
        end

        it 'should return a passing result' do
          expect(call_method).to be_a_passing_result
        end
      end

      describe 'with Symbol keys' do
        let(:data) { { primary_key => primary_key_value } }

        it 'should delegate to the adapter' do
          call_method

          expect(adapter).to have_received(method_name)
        end

        it 'should return a passing result' do
          expect(call_method).to be_a_passing_result
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
            call_method

            expect(adapter).not_to have_received(method_name)
          end

          it 'should return a failing result' do
            expect(call_method)
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
            call_method

            expect(adapter).not_to have_received(method_name)
          end

          it 'should return a failing result' do
            expect(call_method)
              .to be_a_failing_result
              .with_errors(expected_error)
          end
        end
      end
    end
  end

  shared_examples 'should validate the primary key for insertion' do
    describe 'with a nil primary key' do
      let(:data) { super().tap { |hsh| hsh.delete('id') } }
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::PRIMARY_KEY_MISSING,
          params: {},
          path:   [primary_key]
        }
      end

      it 'should not delegate to the adapter' do
        call_method

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a failing result' do
        expect(call_method)
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
        call_method

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a failing result' do
        expect(call_method)
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
        call_method

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a failing result' do
        expect(call_method)
          .to be_a_failing_result
          .with_errors(expected_error)
      end
    end

    context 'when options[:primary_key] is false' do
      let(:options) { super().merge primary_key: false }

      describe 'with a nil primary key' do
        let(:data) { super().tap { |hsh| hsh.delete primary_key.to_s } }

        it 'should delegate to the adapter' do
          call_method

          expect(adapter).to have_received(method_name)
        end

        it 'should return a passing result' do
          expect(call_method).to be_a_passing_result
        end
      end

      describe 'with a primary key with invalid type' do
        let(:primary_key_value) { Object.new }
        let(:data) do
          super().merge(primary_key => primary_key_value)
        end

        it 'should delegate to the adapter' do
          call_method

          expect(adapter).to have_received(method_name)
        end

        it 'should return a passing result' do
          expect(call_method).to be_a_passing_result
        end
      end

      describe 'with an empty primary key' do
        let(:primary_key_type)  { String }
        let(:primary_key_value) { '' }
        let(:data) do
          super().merge(primary_key => primary_key_value)
        end

        it 'should delegate to the adapter' do
          call_method

          expect(adapter).to have_received(method_name)
        end

        it 'should return a passing result' do
          expect(call_method).to be_a_passing_result
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
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
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
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
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
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end
    end

    wrap_context 'when the definition is an entity class' do
      let(:data) { super().tap { |hsh| hsh.delete(primary_key.to_s) } }

      describe 'with a nil primary key' do
        let(:expected_error) do
          {
            type:   Bronze::Collections::Errors::PRIMARY_KEY_MISSING,
            params: {},
            path:   [primary_key]
          }
        end

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
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
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end

      describe 'with an empty primary key' do
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
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end

      wrap_context 'when initialized with an entity transform' do
        let(:object) { definition.new(data) }

        describe 'with a nil primary key' do
          let(:expected_error) do
            {
              type:   Bronze::Collections::Errors::PRIMARY_KEY_MISSING,
              params: {},
              path:   [primary_key]
            }
          end

          before(:example) { object.send(:"#{primary_key}=", nil) }

          it 'should not delegate to the adapter' do
            call_method

            expect(adapter).not_to have_received(method_name)
          end

          it 'should return a failing result' do
            expect(call_method)
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

          before(:example) do
            object.send(:"#{primary_key}=", primary_key_value)
          end

          it 'should not delegate to the adapter' do
            call_method

            expect(adapter).not_to have_received(method_name)
          end

          it 'should return a failing result' do
            expect(call_method)
              .to be_a_failing_result
              .with_errors(expected_error)
          end
        end

        describe 'with an empty primary key' do
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
            call_method

            expect(adapter).not_to have_received(method_name)
          end

          it 'should return a failing result' do
            expect(call_method)
              .to be_a_failing_result
              .with_errors(expected_error)
          end
        end
      end
    end

    wrap_context 'when initialized with a transform' do
      let(:data) { super().tap { |hsh| hsh.delete('id') } }

      describe 'with a nil primary key' do
        let(:expected_error) do
          {
            type:   Bronze::Collections::Errors::PRIMARY_KEY_MISSING,
            params: {},
            path:   [primary_key]
          }
        end

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
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
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
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
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end

      context 'when options[:primary_key] is false' do
        let(:options) { super().merge primary_key: false }

        describe 'with a nil primary key' do
          let(:data) { super().tap { |hsh| hsh.delete primary_key.to_s } }

          it 'should delegate to the adapter' do
            call_method

            expect(adapter).to have_received(method_name)
          end

          it 'should return a passing result' do
            expect(call_method).to be_a_passing_result
          end
        end

        describe 'with a primary key with invalid type' do
          let(:primary_key_value) { Object.new }
          let(:data) do
            super().merge(primary_key => primary_key_value)
          end

          it 'should delegate to the adapter' do
            call_method

            expect(adapter).to have_received(method_name)
          end

          it 'should return a passing result' do
            expect(call_method).to be_a_passing_result
          end
        end

        describe 'with an empty primary key' do
          let(:primary_key_type)  { String }
          let(:primary_key_value) { '' }
          let(:data) do
            super().merge(primary_key => primary_key_value)
          end

          it 'should delegate to the adapter' do
            call_method

            expect(adapter).to have_received(method_name)
          end

          it 'should return a passing result' do
            expect(call_method).to be_a_passing_result
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
            call_method

            expect(adapter).not_to have_received(method_name)
          end

          it 'should return a failing result' do
            expect(call_method)
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
            call_method

            expect(adapter).not_to have_received(method_name)
          end

          it 'should return a failing result' do
            expect(call_method)
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
            call_method

            expect(adapter).not_to have_received(method_name)
          end

          it 'should return a failing result' do
            expect(call_method)
              .to be_a_failing_result
              .with_errors(expected_error)
          end
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
        call_method

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a failing result' do
        expect(call_method)
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
        call_method

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a failing result' do
        expect(call_method)
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
        call_method

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a failing result' do
        expect(call_method)
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
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end

      describe 'with a primary key with invalid type' do
        let(:primary_key_value) { Object.new }
        let(:expected_error)    { Bronze::Collections::Errors::NO_PRIMARY_KEY }

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end

      describe 'with an empty primary key' do
        let(:primary_key_type)  { String }
        let(:primary_key_value) { '' }
        let(:expected_error)    { Bronze::Collections::Errors::NO_PRIMARY_KEY }

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end

      describe 'with a valid primary key' do
        let(:expected_error) { Bronze::Collections::Errors::NO_PRIMARY_KEY }

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
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
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
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
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
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
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
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
        call_method

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a failing result' do
        expect(call_method)
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
        call_method

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a failing result' do
        expect(call_method)
          .to be_a_failing_result
          .with_errors(expected_error)
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
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
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
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
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
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
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
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
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
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_errors(expected_error)
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
        {
          type:   Bronze::Collections::Errors::SELECTOR_MISSING,
          params: {}
        }
      end

      it 'should not delegate to the adapter' do
        call_method

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a failing result' do
        expect(call_method)
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
        call_method

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a failing result' do
        expect(call_method)
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
      find_matching:       Bronze::Result.new,
      find_one:            Bronze::Result.new,
      insert_one:          Bronze::Result.new,
      null_query:          null_query,
      query:               query,
      update_matching:     Bronze::Result.new,
      update_one:          Bronze::Result.new
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

  def tools
    SleepingKingStudios::Tools::Toolbelt.instance
  end

  describe '::new' do
    it 'should define the constructor' do # rubocop:disable RSpec/ExampleLength
      expect(described_class)
        .to be_constructible
        .with(1).argument
        .and_keywords(
          :adapter,
          :name,
          :primary_key,
          :primary_key_type,
          :transform
        )
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
    shared_context 'when the adapter result includes data' do
      let(:result_data) do
        [
          {
            'uuid'   => '00000000-0000-0000-0000-000000000000',
            'title'  => 'Romance of the Three Kingdoms',
            'author' => 'Luo Guanzhong'
          },
          {
            'uuid'   => '00000000-0000-0000-0000-000000000001',
            'title'  => 'Journey to the West',
            'author' => "Wu Cheng'en"
          },
          {
            'uuid'   => '00000000-0000-0000-0000-000000000002',
            'title'  => 'Dream of the Red Chamber',
            'author' => 'Cao Xueqin'
          }
        ]
      end
      let(:value) { { count: 3, data: result_data } }
    end

    shared_examples 'should delegate to the adapter' do
      describe 'with an empty Hash selector' do
        let(:selector) { {} }
        let(:result)   { Bronze::Result.new.tap { |res| res.value = value } }

        it 'should delegate to the adapter' do
          collection.delete_matching(selector)

          expect(adapter)
            .to have_received(:delete_matching)
            .with(collection_name: collection.name, selector: selector)
        end

        it 'should return a passing result' do
          allow(adapter).to receive(:delete_matching).and_return(result)

          expect(collection.delete_matching(selector))
            .to be_a_passing_result
            .with_value(expected)
        end
      end

      describe 'with a non-empty Hash selector' do
        let(:selector) { { author: 'Luo Guanzhong' } }
        let(:result)   { Bronze::Result.new.tap { |res| res.value = value } }

        it 'should delegate to the adapter' do
          collection.delete_matching(selector)

          expect(adapter)
            .to have_received(:delete_matching)
            .with(collection_name: collection.name, selector: selector)
        end

        it 'should return a passing result' do
          allow(adapter).to receive(:delete_matching).and_return(result)

          expect(collection.delete_matching(selector))
            .to be_a_passing_result
            .with_value(expected)
        end
      end
    end

    let(:method_name) { :delete_matching }
    let(:selector)    { nil }
    let(:value)       { { count: 3 } }
    let(:expected)    { value }

    def call_method
      collection.delete_matching(selector)
    end

    it { expect(collection).to respond_to(:delete_matching).with(1).arguments }

    include_examples 'should validate the selector'

    include_examples 'should delegate to the adapter'

    wrap_context 'when the adapter result includes data' do
      include_examples 'should delegate to the adapter'
    end

    wrap_context 'when the definition is an entity class' do
      include_examples 'should delegate to the adapter'

      wrap_context 'when the adapter result includes data' do
        include_examples 'should delegate to the adapter'
      end

      wrap_context 'when initialized with an entity transform' do
        include_examples 'should delegate to the adapter'

        wrap_context 'when the adapter result includes data' do
          let(:transformed_data) do
            result_data.map { |item| transform.denormalize(item) }
          end
          let(:expected) { super().merge(data: transformed_data) }

          include_examples 'should delegate to the adapter'
        end
      end
    end

    wrap_context 'when initialized with a transform' do
      include_examples 'should delegate to the adapter'

      wrap_context 'when the adapter result includes data' do
        let(:transformed_data) do
          result_data.map { |item| transform.denormalize(item) }
        end
        let(:expected) { super().merge(data: transformed_data) }

        include_examples 'should delegate to the adapter'
      end
    end
  end

  describe '#delete_one' do
    shared_examples 'should delegate to the adapter' do
      describe 'with a valid primary key' do
        let(:result) { Bronze::Result.new(value) }

        it 'should delegate to the adapter' do
          collection.delete_one(primary_key_value)

          expect(adapter)
            .to have_received(:delete_one)
            .with(expected_keywords)
        end

        it 'should return a passing result' do
          allow(adapter).to receive(:delete_one).and_return(result)

          expect(collection.delete_one(primary_key_value))
            .to be_a_passing_result
            .with_value(expected)
        end
      end
    end

    let(:primary_key)       { :id }
    let(:primary_key_type)  { String }
    let(:primary_key_value) { '00000000-0000-0000-0000-000000000000' }
    let(:method_name)       { :delete_one }
    let(:value) do
      {
        'uuid'   => '00000000-0000-0000-0000-000000000000',
        'title'  => 'Romance of the Three Kingdoms',
        'author' => 'Luo Guanzhong'
      }
    end
    let(:expected) { value }
    let(:expected_keywords) do
      {
        collection_name:   collection.name,
        primary_key:       primary_key,
        primary_key_value: primary_key_value
      }
    end
    let(:options) { super().merge primary_key_type: primary_key_type }

    def call_method
      collection.delete_one(primary_key_value)
    end

    it { expect(collection).to respond_to(:delete_one).with(1).argument }

    it { expect(collection).to alias_method(:delete_one).as(:delete) }

    include_examples 'should validate the primary key for querying'

    include_examples 'should delegate to the adapter'

    wrap_context 'when the definition is an entity class' do
      include_examples 'should delegate to the adapter'

      wrap_context 'when initialized with an entity transform' do
        let(:expected) { transform.denormalize(value) }

        include_examples 'should delegate to the adapter'
      end
    end

    wrap_context 'when initialized with a transform' do
      let(:expected) { transform.denormalize(value) }

      include_examples 'should delegate to the adapter'
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
    shared_examples 'should delegate to the adapter' do
      it 'should delegate to the adapter' do
        collection.find_matching(selector)

        expect(adapter)
          .to have_received(:find_matching)
          .with(expected_keywords)
      end

      it 'should return the result from the adapter' do
        allow(adapter).to receive(:find_matching).and_return(result)

        expect(collection.find_matching(selector)).to be result
      end

      describe 'with limit: value' do
        let(:method_options) { super().merge limit: 3 }

        it 'should delegate to the adapter' do
          collection.find_matching(selector, limit: 3)

          expect(adapter)
            .to have_received(:find_matching)
            .with(expected_keywords)
        end

        it 'should return the result from the adapter' do
          allow(adapter).to receive(:find_matching).and_return(result)

          expect(collection.find_matching(selector, limit: 3)).to be result
        end
      end

      describe 'with order: value' do
        let(:method_options) { super().merge order: :title }

        it 'should delegate to the adapter' do
          collection.find_matching(selector, order: :title)

          expect(adapter)
            .to have_received(:find_matching)
            .with(expected_keywords)
        end

        it 'should return the result from the adapter' do
          allow(adapter).to receive(:find_matching).and_return(result)

          expect(collection.find_matching(selector, order: :title)).to be result
        end
      end

      describe 'with offset: value' do
        let(:method_options) { super().merge offset: 3 }

        it 'should delegate to the adapter' do
          collection.find_matching(selector, offset: 3)

          expect(adapter)
            .to have_received(:find_matching)
            .with(expected_keywords)
        end

        it 'should return the result from the adapter' do
          allow(adapter).to receive(:find_matching).and_return(result)

          expect(collection.find_matching(selector, offset: 3)).to be result
        end
      end

      describe 'with multiple options' do
        let(:method_options) do
          super().merge limit: 4, offset: 2, order: :title
        end

        it 'should delegate to the adapter' do
          collection.find_matching(selector, limit: 4, offset: 2, order: :title)

          expect(adapter)
            .to have_received(:find_matching)
            .with(expected_keywords)
        end

        # rubocop:disable RSpec/ExampleLength
        it 'should return the result from the adapter' do
          allow(adapter).to receive(:find_matching).and_return(result)

          expect(
            collection.find_matching(
              selector,
              limit:  4,
              offset: 2,
              order:  :title
            )
          ).to be result
        end
        # rubocop:enable RSpec/ExampleLength
      end
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
    let(:expected) do
      {
        'title'    => 'Romance of the Three Kingdoms',
        'author'   => 'Luo Guanzhong',
        'language' => 'Chinese'
      }
    end
    let(:result) { Bronze::Result.new([expected]) }
    let(:expected_keywords) do
      {
        collection_name: collection.name,
        selector:        selector,
        transform:       nil,
        **delegated_options
      }
    end

    def call_method
      collection.find_matching(selector)
    end

    it 'should define the method' do
      expect(collection)
        .to respond_to(:find_matching)
        .with(1).argument
        .and_keywords(:limit, :offset, :order)
    end

    include_examples 'should validate the selector'

    describe 'with an empty Hash selector' do
      let(:selector) { {} }

      include_examples 'should delegate to the adapter'
    end

    describe 'with a non-empty Hash selector' do
      let(:selector) { { author: 'Luo Guanzhong' } }

      include_examples 'should delegate to the adapter'
    end

    wrap_context 'when the definition is an entity class' do
      let(:expected_keywords) do
        super().merge(transform: collection.transform)
      end

      include_examples 'should validate the selector'

      describe 'with an empty Hash selector' do
        let(:selector) { {} }

        include_examples 'should delegate to the adapter'
      end

      describe 'with a non-empty Hash selector' do
        let(:selector) { { author: 'Luo Guanzhong' } }

        include_examples 'should delegate to the adapter'
      end
    end

    wrap_context 'when initialized with a transform' do
      let(:expected_keywords) do
        super().merge(transform: transform)
      end

      include_examples 'should validate the selector'

      describe 'with an empty Hash selector' do
        let(:selector) { {} }

        include_examples 'should delegate to the adapter'
      end

      describe 'with a non-empty Hash selector' do
        let(:selector) { { author: 'Luo Guanzhong' } }

        include_examples 'should delegate to the adapter'
      end
    end
  end

  describe '#find_one' do
    shared_examples 'should delegate to the adapter' do
      include_examples 'should validate the primary key for querying'

      describe 'with a valid primary key' do
        let(:result) { Bronze::Result.new(data) }

        it 'should delegate to the adapter' do
          collection.find_one(primary_key_value)

          expect(adapter)
            .to have_received(:find_one)
            .with(expected_keywords)
        end

        it 'should return the result from the adapter' do
          allow(adapter).to receive(:find_one).and_return(result)

          expect(collection.find_one(primary_key_value)).to be result
        end
      end
    end

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
    let(:expected_keywords) do
      {
        collection_name:   collection.name,
        primary_key:       primary_key,
        primary_key_value: primary_key_value,
        transform:         nil
      }
    end

    def call_method
      collection.find_one(primary_key_value)
    end

    it { expect(collection).to respond_to(:find_one).with(1).argument }

    it { expect(collection).to alias_method(:find_one).as(:find) }

    include_examples 'should delegate to the adapter'

    wrap_context 'when the definition is an entity class' do
      let(:primary_key_value) { '00000000-0000-0000-0000-000000000000' }
      let(:expected_keywords) do
        super().merge(transform: collection.transform)
      end

      include_examples 'should delegate to the adapter'
    end

    wrap_context 'when initialized with a transform' do
      let(:expected_keywords) do
        super().merge(transform: transform)
      end

      include_examples 'should delegate to the adapter'
    end
  end

  describe '#insert_one' do
    let(:primary_key)       { :id }
    let(:primary_key_type)  { String }
    let(:primary_key_value) { '0xFF' }
    let(:method_name)       { :insert_one }
    let(:data) do
      {
        primary_key.to_s => primary_key_value,
        'title'          => 'Romance of the Three Kingdoms',
        'author'         => 'Luo Guanzhong'
      }
    end
    let(:object) { data }

    def call_method
      collection.insert_one(object)
    end

    it { expect(collection).to respond_to(:insert_one).with(1).argument }

    it { expect(collection).to alias_method(:insert_one).as(:insert) }

    include_examples 'should validate the data object'

    include_examples 'should validate the primary key for insertion'

    describe 'with an empty data object' do
      let(:data) { {} }
      let(:expected_error) do
        {
          type:   Bronze::Collections::Errors::DATA_EMPTY,
          params: { data: object }
        }
      end

      it 'should not delegate to the adapter' do
        call_method

        expect(adapter).not_to have_received(method_name)
      end

      it 'should return a failing result' do
        expect(call_method)
          .to be_a_failing_result
          .with_errors(expected_error)
      end
    end

    describe 'with a valid data object with String keys' do
      let(:result) { Bronze::Result.new(data) }

      it 'should delegate to the adapter' do
        collection.insert_one(data)

        expect(adapter)
          .to have_received(:insert_one)
          .with(collection_name: collection.name, data: data)
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
          .with(collection_name: collection.name, data: data)
      end

      it 'should return the result from the adapter' do
        allow(adapter).to receive(:insert_one).and_return(result)

        expect(collection.insert_one(data)).to be result
      end
    end

    wrap_context 'when the definition is an entity class' do
      let(:primary_key_value) { '00000000-0000-0000-0000-000000000000' }

      include_examples 'should validate the data object'

      describe 'with a valid data object with String keys' do
        let(:result) { Bronze::Result.new(data) }

        it 'should delegate to the adapter' do
          collection.insert_one(data)

          expect(adapter)
            .to have_received(:insert_one)
            .with(collection_name: collection.name, data: data)
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
            .with(collection_name: collection.name, data: data)
        end

        it 'should return the result from the adapter' do
          allow(adapter).to receive(:insert_one).and_return(result)

          expect(collection.insert_one(data)).to be result
        end
      end

      wrap_context 'when initialized with an entity transform' do
        let(:object) { definition.new(data) }

        include_examples 'should validate the data object'

        describe 'with a valid entity' do
          let(:primary_key_value) { '00000000-0000-0000-0000-000000000000' }
          let(:expected)          { definition.new(data) }
          let(:attributes)        { collection.transform.normalize(expected) }

          before(:example) do
            allow(adapter)
              .to receive(:insert_one)
              .and_return(Bronze::Result.new(data))
          end

          it 'should delegate to the adapter' do
            collection.insert_one(object)

            expect(adapter)
              .to have_received(:insert_one)
              .with(collection_name: collection.name, data: attributes)
          end

          it 'should wrap the result from the adapter' do
            expect(collection.insert_one(object))
              .to be_a_passing_result.with_value(expected)
          end
        end
      end
    end

    wrap_context 'when initialized with a transform' do
      let(:object) { transform.denormalize(data) }

      include_examples 'should validate the data object'

      describe 'with an empty data object' do
        let(:data) { {} }
        let(:expected_error) do
          {
            type:   Bronze::Collections::Errors::DATA_EMPTY,
            params: { data: object }
          }
        end

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end

      describe 'with a valid data object with String keys' do
        let(:expected) { transform.denormalize(data) }

        before(:example) do
          allow(adapter)
            .to receive(:insert_one)
            .and_return(Bronze::Result.new(data))
        end

        it 'should delegate to the adapter' do
          collection.insert_one(object)

          expect(adapter)
            .to have_received(:insert_one)
            .with(collection_name: collection.name, data: data)
        end

        it 'should wrap the result from the adapter' do
          expect(collection.insert_one(object))
            .to be_a_passing_result.with_value(expected)
        end
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
    include_examples 'should have reader', :primary_key, :id

    context 'when options[:primary_key] is false' do
      let(:options) { super().merge primary_key: false }

      it { expect(collection.primary_key).to be nil }
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
      it { expect(collection.primary_key).to be primary_key }
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
    end
  end

  describe '#query' do
    it { expect(collection).to respond_to(:query).with(0).arguments }

    it { expect(collection).to alias_method(:query).as(:all) }

    it 'should delegate to the adapter' do
      collection.query

      expect(adapter)
        .to have_received(:query)
        .with(collection_name: collection.name, transform: nil)
    end

    it { expect(collection.query).to be query }

    wrap_context 'when initialized with a transform' do
      it 'should delegate to the adapter' do
        collection.query

        expect(adapter)
          .to have_received(:query)
          .with(collection_name: collection.name, transform: transform)
      end

      it { expect(collection.query).to be query }
    end

    wrap_context 'when the definition is an entity class' do
      # rubocop:disable RSpec/ExampleLength
      it 'should delegate to the adapter' do
        collection.query

        expect(adapter)
          .to have_received(:query)
          .with(
            collection_name: collection.name,
            transform:       collection.transform
          )
      end
      # rubocop:enable RSpec/ExampleLength

      it { expect(collection.query).to be query }
    end
  end

  describe '#transform' do
    include_examples 'should have reader', :transform, nil

    wrap_context 'when initialized with a transform' do
      it { expect(collection.transform).to be transform }
    end

    wrap_context 'when the definition is an entity class' do
      it { expect(collection.transform).to be nil }

      wrap_context 'when initialized with an entity transform' do
        it { expect(collection.transform).to be transform }
      end
    end
  end

  describe '#update_matching' do
    shared_context 'when the adapter result includes data' do
      let(:result_data) do
        [
          {
            'uuid'   => '00000000-0000-0000-0000-000000000000',
            'title'  => 'Romance of the Three Kingdoms',
            'author' => 'Luo Guanzhong'
          },
          {
            'uuid'   => '00000000-0000-0000-0000-000000000001',
            'title'  => 'Journey to the West',
            'author' => "Wu Cheng'en"
          },
          {
            'uuid'   => '00000000-0000-0000-0000-000000000002',
            'title'  => 'Dream of the Red Chamber',
            'author' => 'Cao Xueqin'
          }
        ]
      end
      let(:value) { { count: 3, data: result_data } }
    end

    shared_examples 'should delegate to the adapter' do
      describe 'with an empty data object' do
        let(:data) { {} }
        let(:expected_error) do
          {
            type:   Bronze::Collections::Errors::DATA_EMPTY,
            params: { data: object }
          }
        end

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end

      describe 'with a valid selector and data object with String keys' do
        let(:selector) { { author: 'Luo Guanzhong' } }
        let(:data)     { { 'language' => 'Chinese' } }
        let(:result)   { Bronze::Result.new.tap { |res| res.value = value } }
        let(:expected_keywords) do
          {
            collection_name: collection.name,
            data:            data,
            selector:        selector
          }
        end

        it 'should delegate to the adapter' do
          collection.update_matching(selector, with: data)

          expect(adapter)
            .to have_received(:update_matching)
            .with(expected_keywords)
        end

        it 'should return a passing result' do
          allow(adapter).to receive(:update_matching).and_return(result)

          expect(collection.update_matching(selector, with: data))
            .to be_a_passing_result
            .with_value(expected)
        end
      end

      describe 'with a valid selector and data object with Symbol keys' do
        let(:selector) { { author: 'Luo Guanzhong' } }
        let(:data)     { { language: 'Chinese' } }
        let(:result)   { Bronze::Result.new.tap { |res| res.value = value } }
        let(:expected_keywords) do
          {
            collection_name: collection.name,
            data:            data,
            selector:        selector
          }
        end

        it 'should delegate to the adapter' do
          collection.update_matching(selector, with: data)

          expect(adapter)
            .to have_received(:update_matching)
            .with(expected_keywords)
        end

        it 'should return a passing result' do
          allow(adapter).to receive(:update_matching).and_return(result)

          expect(collection.update_matching(selector, with: data))
            .to be_a_passing_result
            .with_value(expected)
        end
      end
    end

    let(:primary_key)       { :id }
    let(:primary_key_type)  { Integer }
    let(:primary_key_value) { 0 }
    let(:method_name)       { :update_matching }
    let(:selector)          { { key: 'value' } }
    let(:data)              { nil }
    let(:object)            { data }
    let(:value)             { { count: 3 } }
    let(:expected)          { value }

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

    include_examples 'should delegate to the adapter'

    wrap_context 'when the adapter result includes data' do
      include_examples 'should delegate to the adapter'
    end

    wrap_context 'when the definition is an entity class' do
      include_examples 'should delegate to the adapter'

      wrap_context 'when initialized with an entity transform' do
        include_examples 'should delegate to the adapter'

        wrap_context 'when the adapter result includes data' do
          let(:transformed_data) do
            result_data.map { |item| transform.denormalize(item) }
          end
          let(:expected) { super().merge(data: transformed_data) }

          include_examples 'should delegate to the adapter'
        end
      end
    end

    wrap_context 'when initialized with a transform' do
      include_examples 'should delegate to the adapter'

      wrap_context 'when the adapter result includes data' do
        let(:transformed_data) do
          result_data.map { |item| transform.denormalize(item) }
        end
        let(:expected) { super().merge(data: transformed_data) }

        include_examples 'should delegate to the adapter'
      end
    end
  end

  describe '#update_one' do
    shared_examples 'should delegate to the adapter' do
      describe 'with an empty data object' do
        let(:data) { {} }
        let(:expected_error) do
          {
            type:   Bronze::Collections::Errors::DATA_EMPTY,
            params: { data: object }
          }
        end

        it 'should not delegate to the adapter' do
          call_method

          expect(adapter).not_to have_received(method_name)
        end

        it 'should return a failing result' do
          expect(call_method)
            .to be_a_failing_result
            .with_errors(expected_error)
        end
      end

      describe 'with a valid primary key and data object with String keys' do
        let(:data)   { { 'language' => 'Chinese' } }
        let(:result) { Bronze::Result.new.tap { |res| res.value = value } }

        it 'should delegate to the adapter' do
          collection.update_one(primary_key_value, with: data)

          expect(adapter)
            .to have_received(:update_one)
            .with(expected_keywords)
        end

        it 'should return a passing result' do
          allow(adapter).to receive(:update_one).and_return(result)

          expect(collection.update_one(primary_key_value, with: data))
            .to be_a_passing_result
            .with_value(expected)
        end
      end

      describe 'with a valid primary key and data object with Symbol keys' do
        let(:data)   { { language: 'Chinese' } }
        let(:result) { Bronze::Result.new.tap { |res| res.value = value } }

        it 'should delegate to the adapter' do
          collection.update_one(primary_key_value, with: data)

          expect(adapter)
            .to have_received(:update_one)
            .with(expected_keywords)
        end

        it 'should return a passing result' do
          allow(adapter).to receive(:update_one).and_return(result)

          expect(collection.update_one(primary_key_value, with: data))
            .to be_a_passing_result
            .with_value(expected)
        end
      end
    end

    let(:primary_key)       { :id }
    let(:primary_key_type)  { String }
    let(:primary_key_value) { '00000000-0000-0000-0000-000000000000' }
    let(:method_name)       { :update_one }
    let(:data)              { { language: 'Chinese' } }
    let(:object)            { data }
    let(:value) do
      {
        'uuid'   => '00000000-0000-0000-0000-000000000000',
        'title'  => 'Romance of the Three Kingdoms',
        'author' => 'Luo Guanzhong'
      }
    end
    let(:expected) { value }
    let(:options) do
      super().merge primary_key_type: primary_key_type
    end
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

    include_examples 'should validate the data object'

    include_examples 'should validate the primary key for querying'

    include_examples 'should validate the primary key for updates'

    include_examples 'should delegate to the adapter'

    wrap_context 'when the definition is an entity class' do
      include_examples 'should delegate to the adapter'

      wrap_context 'when initialized with an entity transform' do
        let(:expected) { transform.denormalize(value) }

        include_examples 'should delegate to the adapter'
      end
    end

    wrap_context 'when initialized with a transform' do
      let(:expected) { transform.denormalize(value) }

      include_examples 'should delegate to the adapter'
    end
  end
end
