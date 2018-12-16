# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'support/examples/entities'

module Support::Examples::Entities
  module PrimaryKeyExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when the entity class has a primary key' do
      let(:defined_attributes)  { defined?(super()) ? super() : [] }
      let(:primary_key_name)    { defined?(super()) ? super() : :id }
      let(:primary_key_type)    { defined?(super()) ? super() : Integer }
      let(:primary_key_value)   { defined?(super()) ? super() : 15_151 }
      let(:primary_key_default) do
        next super() if defined?(super())

        next_index = -1

        -> { next_index += 1 }
      end
      let(:primary_key_args) do
        return super() if defined?(super())

        [
          primary_key_name,
          primary_key_type,
          { default: primary_key_default }
        ]
      end

      before(:example) do
        described_class.define_primary_key(*primary_key_args)

        defined_attributes << primary_key_name
      end
    end

    shared_examples 'should implement the PrimaryKey methods' do
      describe '::primary_key' do
        it 'should define the class reader' do
          expect(described_class).to have_reader(:primary_key).with_value(nil)
        end

        wrap_context 'when the entity class has a primary key' do
          let(:metadata) { described_class.primary_key }

          it 'should return the metadata' do
            expect(described_class.primary_key)
              .to be_a Bronze::Entities::Attributes::Metadata
          end

          it { expect(metadata.name).to be primary_key_name }

          it { expect(metadata.type).to be primary_key_type }

          it { expect(metadata.allow_nil?).to be false }

          it { expect(metadata.default).to be_a primary_key_type }

          it { expect(metadata.default?).to be true }

          it { expect(metadata.foreign_key?).to be false }

          it { expect(metadata.primary_key?).to be true }

          it { expect(metadata.read_only?).to be true }
        end

        wrap_context 'with a subclass of the entity class' do
          it { expect(described_class.primary_key).to be nil }

          wrap_context 'when the entity class has a primary key' do
            let(:metadata) { described_class.primary_key }

            it 'should return the metadata' do
              expect(described_class.primary_key)
                .to be_a Bronze::Entities::Attributes::Metadata
            end

            it { expect(metadata.name).to be primary_key_name }

            it { expect(metadata.type).to be primary_key_type }

            it { expect(metadata.allow_nil?).to be false }

            it { expect(metadata.default).to be_a primary_key_type }

            it { expect(metadata.default?).to be true }

            it { expect(metadata.foreign_key?).to be false }

            it { expect(metadata.primary_key?).to be true }

            it { expect(metadata.read_only?).to be true }
          end
        end
      end

      describe '#assign_attributes' do
        wrap_context 'when the entity class has a primary key' do
          describe 'with primary key: value' do
            let(:attributes) do
              { primary_key_name => primary_key_value }
            end

            it 'should not change the primary key' do
              expect { entity.assign_attributes(attributes) }
                .not_to change(entity, primary_key_name)
            end
          end
        end
      end

      describe '#attributes=' do
        wrap_context 'when the entity class has a primary key' do
          describe 'with an empty hash' do
            it 'should not change the attributes' do
              expect { entity.attributes = {} }
                .not_to change(entity, :attributes)
            end
          end

          describe 'with primary key: nil' do
            let(:attributes) { { primary_key_name => nil } }

            it 'should not change the attributes' do
              expect { entity.attributes = attributes }
                .not_to change(entity, :attributes)
            end
          end

          describe 'with primary key: value' do
            let(:attributes) { { primary_key_name => primary_key_value } }

            it 'should update the attributes' do
              expect { entity.attributes = attributes }
                .not_to change(entity, :attributes)
            end
          end
        end
      end

      describe '#primary_key' do
        include_examples 'should have reader', :primary_key, nil

        wrap_context 'when the entity class has a primary key' do
          it { expect(entity.primary_key).to be_a primary_key_type }

          context 'when the entity is initialized with a primary key' do
            let(:initial_attributes) do
              { primary_key_name => primary_key_value }
            end

            it { expect(entity.primary_key).to be == primary_key_value }
          end
        end
      end
    end

    shared_examples 'should implement the generic PrimaryKey methods' do
      describe '::define_primary_key' do
        it 'should define the class method' do
          expect(described_class)
            .to respond_to(:define_primary_key)
            .with(2).arguments
            .and_keywords(:default)
        end

        describe 'with a valid attribute name, type, and default' do
          let(:attribute_name) { :id }
          let(:attribute_type) { Integer }
          let(:attribute_opts) do
            {
              default:     default,
              primary_key: true,
              read_only:   true
            }
          end
          let(:attribute_value) { 0 }
          let(:default) do
            next_index = -1

            -> { next_index += 1 }
          end

          def build_attribute
            entity_class.define_primary_key :id, Integer, default: default
          end

          include_examples 'should define the attribute', read_only: true
        end

        wrap_context 'with a subclass of the entity class' do
          describe 'with a valid attribute name, type, and default' do
            let(:attribute_name) { :id }
            let(:attribute_type) { Integer }
            let(:attribute_opts) do
              {
                default:     default,
                primary_key: true,
                read_only:   true
              }
            end
            let(:attribute_value) { 0 }
            let(:default) do
              next_index = -1

              -> { next_index += 1 }
            end

            def build_attribute
              entity_class.define_primary_key :id, Integer, default: default
            end

            include_examples 'should define the attribute', read_only: true
          end
        end
      end
    end
  end
end
