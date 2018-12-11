# frozen_string_literal: true

require 'date'

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'support/examples/entities'

module Support::Examples::Entities
  module AttributesExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when the entity class has many attributes' do
      let(:defined_attributes) { defined?(super()) ? super() : [] }

      before(:example) do
        described_class.attribute :title,            String
        described_class.attribute :page_count,       Integer
        described_class.attribute :publication_date, Date

        defined_attributes << :title << :page_count << :publication_date
      end
    end

    shared_examples 'should implement the Attributes methods' do
      describe '::attribute' do
        shared_examples 'should define the attribute' do |options = {}|
          let(:metadata) { build_attribute }

          def build_attribute
            described_class
              .attribute(attribute_name, attribute_type, attribute_opts)
          end

          it 'should return the metadata' do
            expect(build_attribute)
              .to be_a Bronze::Entities::Attributes::Metadata
          end

          it 'should set the attribute name' do
            expect(metadata.name).to be == attribute_name.intern
          end

          it 'should set the attribute options' do
            expect(metadata.options).to be == attribute_opts
          end

          it 'should set the attribute type' do
            expect(metadata.type).to be == attribute_type
          end

          describe '#%<attribute>' do
            before(:example) { build_attribute }

            it 'should define the reader method' do
              expect(entity)
                .to have_reader(attribute_name)
                .with_value(initial_attributes[attribute_name.intern])
            end

            context 'when the entity is initialized with attributes' do
              let(:value) { 'attribute value' }
              let(:initial_attributes) do
                super().merge(attribute_name.intern => value)
              end

              it { expect(entity.send attribute_name).to be value }
            end
          end

          describe '#%<attribute>=' do
            let(:value) { 'attribute value' }

            before(:example) { build_attribute }

            # rubocop:disable RSpec/RepeatedDescription
            if options.fetch(:read_only, false)
              it 'should define the writer method' do
                expect(entity)
                  .to respond_to(:"#{attribute_name}=", true)
                  .with(1).argument
              end

              it 'should set the writer method as private' do
                expect(entity).not_to respond_to(:"#{attribute_name}=")
              end
            else
              it 'should define the writer method' do
                expect(entity).to have_writer(:"#{attribute_name}=")
              end
            end
            # rubocop:enable RSpec/RepeatedDescription

            it 'should update the attribute' do
              expect { entity.send(:"#{attribute_name}=", value) }
                .to change { entity.get_attribute(attribute_name.intern) }
                .to be value
            end
          end
        end

        it 'should respond to the method' do
          expect(described_class).to respond_to(:attribute).with(2..3).arguments
        end

        describe 'with a valid attribute name and attribute type' do
          let(:attribute_name) { :title }
          let(:attribute_type) { String }
          let(:attribute_opts) { {} }
          let(:metadata)       { build_attribute }

          include_examples 'should define the attribute'
        end

        describe 'with read_only: true' do
          let(:attribute_name) { :isbn }
          let(:attribute_type) { String }
          let(:attribute_opts) { { read_only: true } }
          let(:metadata)       { build_attribute }

          include_examples 'should define the attribute', read_only: true
        end
      end

      describe '::attributes' do
        it 'should define the class reader' do
          expect(described_class)
            .to have_reader(:attributes)
            .with_value(an_instance_of Hash)
        end

        context 'when the attributes hash is mutated' do
          let(:metadata) do
            Bronze::Entities::Attributes::Metadata.new(:malicious, Object, {})
          end
          let(:error_type) do
            error = RUBY_VERSION >= '2.5.0' ? 'FrozenError' : 'RuntimeError'

            Object.const_get(error)
          end
          let(:error_message) { "can't modify frozen Hash" }

          it 'should raise an error' do
            expect { described_class.attributes[:bogus] = metadata }
              .to raise_error error_type, error_message
          end

          # rubocop:disable RSpec/ExampleLength
          it 'should not change the hash' do
            expect do
              begin
                described_class.attributes[:bogus] = metadata
              rescue error_type # rubocop:disable Lint/HandleExceptions
              end
            end
              .not_to change(described_class, :attributes)
          end
          # rubocop:enable RSpec/ExampleLength
        end

        wrap_context 'when the entity class has many attributes' do
          it 'should have a key for each attribute' do
            expect(described_class.attributes.keys)
              .to contain_exactly(*defined_attributes)
          end

          it 'should have metadata for each attribute' do
            expect(described_class.attributes.values)
              .to all be_a Bronze::Entities::Attributes::Metadata
          end

          it 'should return the metadata for each attribute',
            :aggregate_failures \
          do
            described_class.attributes.each do |name, metadata|
              expect(metadata.name).to be name
            end
          end
        end
      end

      describe '#attribute?' do
        it { expect(entity).to respond_to(:attribute?).with(1).argument }

        it { expect(entity.attribute? nil).to be false }

        it { expect(entity.attribute? 'mystery').to be false }

        it { expect(entity.attribute? :mystery).to be false }

        describe 'with an object' do
          it 'should raise an error' do
            expect { entity.attribute?(Object.new) }
              .to raise_error NoMethodError
          end
        end

        wrap_context 'when the entity class has many attributes' do
          it { expect(entity.attribute? nil).to be false }

          it { expect(entity.attribute? 'mystery').to be false }

          it { expect(entity.attribute? :mystery).to be false }

          it { expect(entity.attribute? 'title').to be true }

          it { expect(entity.attribute? :title).to be true }

          describe 'with an object' do
            it 'should raise an error' do
              expect { entity.attribute?(Object.new) }
                .to raise_error NoMethodError
            end
          end
        end
      end

      describe '#get_attribute' do
        it { expect(entity).to respond_to(:get_attribute).with(1).argument }

        describe 'with nil' do
          let(:error_message) { 'invalid attribute nil' }

          it 'should raise an error' do
            expect { entity.get_attribute(nil) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an Object' do
          it 'should raise an error' do
            expect { entity.get_attribute(Object.new) }
              .to raise_error NoMethodError
          end
        end

        describe 'with an invalid string' do
          let(:error_message) { 'invalid attribute "mystery"' }

          it 'should raise an error' do
            expect { entity.get_attribute('mystery') }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an invalid symbol' do
          let(:error_message) { 'invalid attribute :mystery' }

          it 'should raise an error' do
            expect { entity.get_attribute(:mystery) }
              .to raise_error ArgumentError, error_message
          end
        end

        wrap_context 'when the entity class has many attributes' do
          describe 'with nil' do
            let(:error_message) { 'invalid attribute nil' }

            it 'should raise an error' do
              expect { entity.get_attribute(nil) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with an Object' do
            it 'should raise an error' do
              expect { entity.get_attribute(Object.new) }
                .to raise_error NoMethodError
            end
          end

          describe 'with an invalid string' do
            let(:error_message) { 'invalid attribute "mystery"' }

            it 'should raise an error' do
              expect { entity.get_attribute('mystery') }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with an invalid symbol' do
            let(:error_message) { 'invalid attribute :mystery' }

            it 'should raise an error' do
              expect { entity.get_attribute(:mystery) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with a valid string' do
            it { expect(entity.get_attribute('title')).to be nil }
          end

          describe 'with a valid symbol' do
            it { expect(entity.get_attribute(:title)).to be nil }
          end

          context 'when the entity is initialized with attributes' do
            let(:initial_attributes) do
              super().merge(
                title:            'The Once And Future King',
                publication_date: Date.new(1958, 1, 1)
              )
            end
            let(:expected) { initial_attributes[:title] }

            describe 'with a valid string' do
              it { expect(entity.get_attribute('title')).to be expected }
            end

            describe 'with a valid symbol' do
              it { expect(entity.get_attribute(:title)).to be expected }
            end
          end
        end
      end

      describe '#set_attribute' do
        let(:value) { 'attribute value' }

        it { expect(entity).to respond_to(:set_attribute).with(2).arguments }

        describe 'with nil and a value' do
          let(:error_message) { 'invalid attribute nil' }

          it 'should raise an error' do
            expect { entity.set_attribute(nil, value) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an Object and a value' do
          it 'should raise an error' do
            expect { entity.set_attribute(Object.new, value) }
              .to raise_error NoMethodError
          end
        end

        describe 'with an invalid string and a value' do
          let(:error_message) { 'invalid attribute "mystery"' }

          it 'should raise an error' do
            expect { entity.set_attribute('mystery', value) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an invalid symbol and a value' do
          let(:error_message) { 'invalid attribute :mystery' }

          it 'should raise an error' do
            expect { entity.set_attribute(:mystery, value) }
              .to raise_error ArgumentError, error_message
          end
        end

        wrap_context 'when the entity class has many attributes' do
          describe 'with nil and a value' do
            let(:error_message) { 'invalid attribute nil' }

            it 'should raise an error' do
              expect { entity.set_attribute(nil, value) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with an Object and a value' do
            it 'should raise an error' do
              expect { entity.set_attribute(Object.new, value) }
                .to raise_error NoMethodError
            end
          end

          describe 'with an invalid string and a value' do
            let(:error_message) { 'invalid attribute "mystery"' }

            it 'should raise an error' do
              expect { entity.set_attribute('mystery', value) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with an invalid symbol and a value' do
            let(:error_message) { 'invalid attribute :mystery' }

            it 'should raise an error' do
              expect { entity.set_attribute(:mystery, value) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with a valid string and a value' do
            it 'should update the attributes' do
              expect { entity.set_attribute('title', value) }
                .to change { entity.get_attribute(:title) }
                .to be value
            end
          end

          describe 'with a valid symbol and a value' do
            it 'should update the attributes' do
              expect { entity.set_attribute(:title, value) }
                .to change { entity.get_attribute(:title) }
                .to be value
            end
          end

          context 'when the entity is initialized with attributes' do
            let(:initial_attributes) do
              super().merge(
                title:            'The Once And Future King',
                publication_date: Date.new(1958, 1, 1)
              )
            end
            let(:expected) { initial_attributes[:title] }

            describe 'with a valid string and a value' do
              it 'should update the attributes' do
                expect { entity.set_attribute('title', value) }
                  .to change { entity.get_attribute(:title) }
                  .from(initial_attributes[:title])
                  .to be value
              end
            end

            describe 'with a valid symbol and a value' do
              it 'should update the attributes' do
                expect { entity.set_attribute(:title, value) }
                  .to change { entity.get_attribute(:title) }
                  .from(initial_attributes[:title])
                  .to be value
              end
            end
          end
        end
      end

      pending
    end
  end
end
