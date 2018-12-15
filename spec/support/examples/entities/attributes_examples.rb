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

    shared_context 'when the entity class has an attribute with default block' \
    do
      let(:defined_attributes) { defined?(super()) ? super() : [] }
      let(:series_counter)     { Struct.new(:index).new(0) }

      before(:example) do
        described_class.attribute :series_index,
          Integer,
          default: -> { series_counter.index += 1 }

        defined_attributes << :series_index
      end
    end

    shared_context 'when the entity class has an attribute with default value' \
    do
      let(:defined_attributes) { defined?(super()) ? super() : [] }
      let(:default_introduction) do
        'There was a storm in the city that night, pouring rain like a ' \
        'biblical deluge, the tears of angels sent down from Heaven to ' \
        'wash away the sins of Man.'
      end

      before(:example) do
        described_class.attribute :introduction,
          String,
          default: default_introduction

        defined_attributes << :introduction
      end
    end

    shared_context 'when the entity class has a read-only attribute' do
      let(:defined_attributes) { defined?(super()) ? super() : [] }

      before(:example) do
        described_class.attribute :isbn,
          String,
          read_only: true

        defined_attributes << :isbn
      end
    end

    shared_context 'with a subclass of the entity class' do
      let(:entity_class) { Spec::EntitySubclass }

      example_constant 'Spec::EntitySubclass' do
        Class.new(described_class)
      end
    end

    shared_examples 'should implement the Attributes methods' do
      describe '::new' do
        describe 'with a hash with invalid string keys' do
          let(:mystery) do
            'Princess Pink, in the Playroom, with the Squeaky Mallet'
          end
          let(:error_message) { 'invalid attribute "mystery"' }
          let(:attributes) do
            { 'mystery' => mystery }
          end

          it 'should raise an error' do
            expect { described_class.new(attributes) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with a hash with invalid symbol keys' do
          let(:mystery) do
            'Princess Pink, in the Playroom, with the Squeaky Mallet'
          end
          let(:error_message) { 'invalid attribute :mystery' }
          let(:attributes) do
            {
              mystery: mystery
            }
          end

          it 'should raise an error' do
            expect { described_class.new(attributes) }
              .to raise_error ArgumentError, error_message
          end
        end
      end

      describe '::attribute' do
        shared_examples 'should define the attribute' do |options = {}|
          let(:metadata) { build_attribute }

          def build_attribute
            entity_class
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

          # rubocop:disable RSpec/ExampleLength
          it 'should add the metadata to ::attributes' do
            metadata_class = Bronze::Entities::Attributes::Metadata

            expect { build_attribute }
              .to change(entity_class, :attributes)
              .to(
                satisfy do |hsh|
                  hsh[attribute_name.intern].is_a?(metadata_class)
                end
              )
          end
          # rubocop:enable RSpec/ExampleLength

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
          let(:attribute_name) { :subtitle }
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

        wrap_context 'when the entity class has many attributes' do
          describe 'with a valid attribute name and attribute type' do
            let(:attribute_name) { :subtitle }
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

        wrap_context 'with a subclass of the entity class' do
          describe 'with a valid attribute name and attribute type' do
            let(:attribute_name) { :subtitle }
            let(:attribute_type) { String }
            let(:attribute_opts) { {} }
            let(:metadata)       { build_attribute }

            include_examples 'should define the attribute'

            it 'should not change the parent class' do
              expect { build_attribute }
                .not_to change(described_class, :attributes)
            end
          end

          describe 'with read_only: true' do
            let(:attribute_name) { :isbn }
            let(:attribute_type) { String }
            let(:attribute_opts) { { read_only: true } }
            let(:metadata)       { build_attribute }

            include_examples 'should define the attribute', read_only: true

            it 'should not change the parent class' do
              expect { build_attribute }
                .not_to change(described_class, :attributes)
            end
          end

          wrap_context 'when the entity class has many attributes' do
            describe 'with a valid attribute name and attribute type' do
              let(:attribute_name) { :subtitle }
              let(:attribute_type) { String }
              let(:attribute_opts) { {} }
              let(:metadata)       { build_attribute }

              include_examples 'should define the attribute'

              it 'should not change the parent class' do
                expect { build_attribute }
                  .not_to change(described_class, :attributes)
              end
            end

            describe 'with read_only: true' do
              let(:attribute_name) { :isbn }
              let(:attribute_type) { String }
              let(:attribute_opts) { { read_only: true } }
              let(:metadata)       { build_attribute }

              include_examples 'should define the attribute', read_only: true

              it 'should not change the parent class' do
                expect { build_attribute }
                  .not_to change(described_class, :attributes)
              end
            end
          end
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

        wrap_context 'with a subclass of the entity class' do
          it { expect(entity_class.attributes).to be == {} }

          context 'when the subclass has many attributes' do
            let(:defined_attributes) { defined?(super()) ? super() : [] }

            before(:example) do
              described_class.attribute :imprint,  String
              described_class.attribute :preface,  String
              described_class.attribute :subtitle, String

              defined_attributes << :imprint << :preface << :subtitle
            end

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

            context 'when the subclass has many attributes' do
              before(:example) do
                described_class.attribute :imprint,  String
                described_class.attribute :preface,  String
                described_class.attribute :subtitle, String

                defined_attributes << :imprint << :preface << :subtitle
              end

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
        end
      end

      describe '#==' do
        # rubocop:disable Style/NilComparison
        describe 'with nil' do
          it { expect(entity == nil).to be false }
        end
        # rubocop:enable Style/NilComparison

        describe 'with an Object' do
          it { expect(entity == Object.new).to be false }
        end

        describe 'with an entity with a different class' do
          let(:other_entity_class) { Spec::OtherEntityClass }
          let(:other_entity)       { other_entity_class.new }

          example_class 'Spec::OtherEntityClass' do |klass|
            klass.send :include, Bronze::Entities::Attributes
          end

          it { expect(entity == other_entity).to be false }
        end

        describe 'with an instance of a subclass' do
          let(:other_entity_class) { Class.new(entity_class) }
          let(:other_entity)       { other_entity_class.new }

          it { expect(entity == other_entity).to be false }
        end

        describe 'with a non-matching attributes hash' do
          let(:attributes) { { title: 'Green Eggs And Ham' } }

          it { expect(entity == attributes).to be false }
        end

        describe 'with a matching attributes hash' do
          let(:attributes) { {} }

          it { expect(entity == attributes).to be true }
        end

        describe 'with an entity with the same class' do
          let(:other_entity) { entity_class.new }

          it { expect(entity == other_entity).to be true }
        end

        wrap_context 'when the entity class has many attributes' do
          # rubocop:disable Style/NilComparison
          describe 'with nil' do
            it { expect(entity == nil).to be false }
          end
          # rubocop:enable Style/NilComparison

          describe 'with an Object' do
            it { expect(entity == Object.new).to be false }
          end

          describe 'with an entity with a different class' do
            let(:other_entity_class) { Spec::OtherEntityClass }
            let(:other_entity)       { other_entity_class.new }

            example_class 'Spec::OtherEntityClass' do |klass|
              klass.send :include, Bronze::Entities::Attributes
            end

            it { expect(entity == other_entity).to be false }
          end

          describe 'with an instance of a subclass' do
            let(:other_entity_class) { Class.new(entity_class) }
            let(:other_entity)       { other_entity_class.new }

            it { expect(entity == other_entity).to be false }
          end

          describe 'with a non-matching attributes hash' do
            let(:attributes) do
              {
                title:            'Green Eggs And Ham',
                page_count:       nil,
                publication_date: nil
              }
            end

            it { expect(entity == attributes).to be false }
          end

          describe 'with a matching attributes hash' do
            let(:attributes) do
              {
                title:            nil,
                page_count:       nil,
                publication_date: nil
              }
            end

            it { expect(entity == attributes).to be true }
          end

          describe 'with an entity with non-matching attributes' do
            let(:attributes) do
              {
                title:            'Green Eggs And Ham',
                page_count:       nil,
                publication_date: nil
              }
            end
            let(:other_entity) { entity_class.new(attributes) }

            it { expect(entity == other_entity).to be false }
          end

          describe 'with an entity with matching attributes' do
            let(:attributes) do
              {
                title:            nil,
                page_count:       nil,
                publication_date: nil
              }
            end
            let(:other_entity) { entity_class.new(attributes) }

            it { expect(entity == other_entity).to be true }
          end

          context 'when the entity is initialized with attributes' do
            let(:initial_attributes) do
              super().merge(
                title:            'The Once And Future King',
                publication_date: Date.new(1958, 1, 1)
              )
            end

            describe 'with a non-matching attributes hash' do
              let(:attributes) do
                {
                  title:            'Green Eggs And Ham',
                  page_count:       nil,
                  publication_date: nil
                }
              end

              it { expect(entity == attributes).to be false }
            end

            describe 'with a matching attributes hash' do
              let(:attributes) do
                {
                  title:            initial_attributes[:title],
                  page_count:       nil,
                  publication_date: initial_attributes[:publication_date]
                }
              end

              it { expect(entity == attributes).to be true }
            end

            describe 'with an entity with non-matching attributes' do
              let(:attributes) do
                {
                  title:            'Green Eggs And Ham',
                  page_count:       nil,
                  publication_date: nil
                }
              end
              let(:other_entity) { entity_class.new(attributes) }

              it { expect(entity == other_entity).to be false }
            end

            describe 'with an entity with matching attributes' do
              let(:attributes) do
                {
                  title:            initial_attributes[:title],
                  page_count:       nil,
                  publication_date: initial_attributes[:publication_date]
                }
              end
              let(:other_entity) { entity_class.new(attributes) }

              it { expect(entity == other_entity).to be true }
            end
          end
        end
      end

      describe '#assign_attributes' do
        it 'should define the method' do
          expect(entity).to respond_to(:assign_attributes).with(1).arguments
        end

        it { expect(entity).to alias_method(:assign_attributes).as(:assign) }

        describe 'with nil' do
          let(:error_message) do
            'expected attributes to be a Hash, but was nil'
          end

          it 'should raise an error' do
            expect { entity.assign_attributes nil }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an empty hash' do
          it 'should not change the attributes' do
            expect { entity.assign_attributes({}) }
              .not_to change(entity, :attributes)
          end
        end

        describe 'with a hash with invalid string keys' do
          let(:mystery) do
            'Princess Pink, in the Playroom, with the Squeaky Mallet'
          end
          let(:error_message) { 'invalid attribute "mystery"' }
          let(:attributes)    { { 'mystery' => mystery } }

          it 'should raise an error' do
            expect { entity.assign_attributes(attributes) }
              .to raise_error ArgumentError, error_message
          end

          # rubocop:disable Lint/HandleExceptions
          # rubocop:disable RSpec/ExampleLength
          it 'should not change the attributes' do
            expect do
              begin
                entity.attributes = attributes
              rescue ArgumentError
              end
            end
              .not_to change(entity, :attributes)
          end
          # rubocop:enable Lint/HandleExceptions
          # rubocop:enable RSpec/ExampleLength
        end

        describe 'with a hash with invalid symbol keys' do
          let(:mystery) do
            'Princess Pink, in the Playroom, with the Squeaky Mallet'
          end
          let(:error_message) { 'invalid attribute :mystery' }
          let(:attributes)    { { mystery: mystery } }

          it 'should raise an error' do
            expect { entity.assign_attributes(attributes) }
              .to raise_error ArgumentError, error_message
          end

          # rubocop:disable Lint/HandleExceptions
          # rubocop:disable RSpec/ExampleLength
          it 'should not change the attributes' do
            expect do
              begin
                entity.attributes = attributes
              rescue ArgumentError
              end
            end
              .not_to change(entity, :attributes)
          end
          # rubocop:enable Lint/HandleExceptions
          # rubocop:enable RSpec/ExampleLength
        end

        wrap_context 'when the entity class has many attributes' do
          describe 'with nil' do
            let(:error_message) do
              'expected attributes to be a Hash, but was nil'
            end

            it 'should raise an error' do
              expect { entity.assign_attributes nil }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with an empty hash' do
            it 'should not change the attributes' do
              expect { entity.assign_attributes({}) }
                .not_to change(entity, :attributes)
            end
          end

          describe 'with a hash with invalid string keys' do
            let(:mystery) do
              'Princess Pink, in the Playroom, with the Squeaky Mallet'
            end
            let(:error_message) { 'invalid attribute "mystery"' }
            let(:attributes)    { { 'mystery' => mystery } }

            it 'should raise an error' do
              expect { entity.assign_attributes(attributes) }
                .to raise_error ArgumentError, error_message
            end

            # rubocop:disable Lint/HandleExceptions
            # rubocop:disable RSpec/ExampleLength
            it 'should not change the attributes' do
              expect do
                begin
                  entity.attributes = attributes
                rescue ArgumentError
                end
              end
                .not_to change(entity, :attributes)
            end
            # rubocop:enable Lint/HandleExceptions
            # rubocop:enable RSpec/ExampleLength
          end

          describe 'with a hash with invalid symbol keys' do
            let(:mystery) do
              'Princess Pink, in the Playroom, with the Squeaky Mallet'
            end
            let(:error_message) { 'invalid attribute :mystery' }
            let(:attributes)    { { mystery: mystery } }

            it 'should raise an error' do
              expect { entity.assign_attributes(attributes) }
                .to raise_error ArgumentError, error_message
            end

            # rubocop:disable Lint/HandleExceptions
            # rubocop:disable RSpec/ExampleLength
            it 'should not change the attributes' do
              expect do
                begin
                  entity.attributes = attributes
                rescue ArgumentError
                end
              end
                .not_to change(entity, :attributes)
            end
            # rubocop:enable Lint/HandleExceptions
            # rubocop:enable RSpec/ExampleLength
          end

          describe 'with a hash with valid string keys' do
            let(:attributes) do
              {
                'title'      => 'The Lay of Beleriand',
                'page_count' => 500
              }
            end
            let(:expected) do
              {
                title:            attributes['title'],
                page_count:       attributes['page_count'],
                publication_date: nil
              }
            end

            it 'should set the attributes' do
              expect { entity.assign_attributes(attributes) }
                .to change(entity, :attributes)
                .to be == expected
            end
          end

          describe 'with a hash with valid symbol keys' do
            let(:attributes) do
              {
                title:      'The Lay of Beleriand',
                page_count: 500
              }
            end
            let(:expected) do
              {
                title:            attributes[:title],
                page_count:       attributes[:page_count],
                publication_date: nil
              }
            end

            it 'should set the attributes' do
              expect { entity.assign_attributes(attributes) }
                .to change(entity, :attributes)
                .to be == expected
            end
          end

          context 'when the entity is initialized with attributes' do
            let(:initial_attributes) do
              super().merge(
                title:            'The Once And Future King',
                publication_date: Date.new(1958, 1, 1)
              )
            end

            describe 'with an empty hash' do
              it 'should not change the attributes' do
                expect { entity.assign_attributes({}) }
                  .not_to change(entity, :attributes)
              end
            end

            describe 'with a hash with invalid string keys' do
              let(:mystery) do
                'Princess Pink, in the Playroom, with the Squeaky Mallet'
              end
              let(:error_message) { 'invalid attribute "mystery"' }
              let(:attributes)    { { 'mystery' => mystery } }

              it 'should raise an error' do
                expect { entity.assign_attributes(attributes) }
                  .to raise_error ArgumentError, error_message
              end

              # rubocop:disable Lint/HandleExceptions
              # rubocop:disable RSpec/ExampleLength
              it 'should not change the attributes' do
                expect do
                  begin
                    entity.attributes = attributes
                  rescue ArgumentError
                  end
                end
                  .not_to change(entity, :attributes)
              end
              # rubocop:enable Lint/HandleExceptions
              # rubocop:enable RSpec/ExampleLength
            end

            describe 'with a hash with invalid symbol keys' do
              let(:mystery) do
                'Princess Pink, in the Playroom, with the Squeaky Mallet'
              end
              let(:error_message) { 'invalid attribute :mystery' }
              let(:attributes)    { { mystery: mystery } }

              it 'should raise an error' do
                expect { entity.assign_attributes(attributes) }
                  .to raise_error ArgumentError, error_message
              end

              # rubocop:disable Lint/HandleExceptions
              # rubocop:disable RSpec/ExampleLength
              it 'should not change the attributes' do
                expect do
                  begin
                    entity.attributes = attributes
                  rescue ArgumentError
                  end
                end
                  .not_to change(entity, :attributes)
              end
              # rubocop:enable Lint/HandleExceptions
              # rubocop:enable RSpec/ExampleLength
            end

            describe 'with a hash with valid string keys' do
              let(:attributes) do
                {
                  'title'      => 'The Lay of Beleriand',
                  'page_count' => 500
                }
              end
              let(:expected) do
                {
                  title:            attributes['title'],
                  page_count:       attributes['page_count'],
                  publication_date: initial_attributes[:publication_date]
                }
              end

              it 'should set the attributes' do
                expect { entity.assign_attributes(attributes) }
                  .to change(entity, :attributes)
                  .to be == expected
              end
            end

            describe 'with a hash with valid symbol keys' do
              let(:attributes) do
                {
                  title:      'The Lay of Beleriand',
                  page_count: 500
                }
              end
              let(:expected) do
                {
                  title:            attributes[:title],
                  page_count:       attributes[:page_count],
                  publication_date: initial_attributes[:publication_date]
                }
              end

              it 'should set the attributes' do
                expect { entity.assign_attributes(attributes) }
                  .to change(entity, :attributes)
                  .to be == expected
              end
            end
          end
        end

        wrap_context \
          'when the entity class has an attribute with default value' \
        do
          describe 'with an empty hash' do
            let(:expected) { { introduction: nil } }

            it 'should not change the attributes' do
              expect { entity.assign_attributes({}) }
                .not_to change(entity, :attributes)
            end
          end

          describe 'with attribute: nil' do
            let(:expected) { { introduction: nil } }

            it 'should update the attributes' do
              expect { entity.assign_attributes(introduction: nil) }
                .to change(entity, :attributes)
                .to be == expected
            end
          end

          describe 'with attribute: value' do
            let(:introduction) do
              'It was the best of times, it was the worst of times.'
            end
            let(:expected) { { introduction: introduction } }

            it 'should update the attributes' do
              expect { entity.assign_attributes(introduction: introduction) }
                .to change(entity, :attributes)
                .to be == expected
            end
          end

          context 'when the entity is initialized with attributes' do
            let(:custom_introduction) do
              'In a hole in the ground there lived a hobbit.'
            end
            let(:initial_attributes) do
              super().merge(introduction: custom_introduction)
            end

            describe 'with an empty hash' do
              let(:expected) { { introduction: nil } }

              it 'should not change the attributes' do
                expect { entity.assign_attributes({}) }
                  .not_to change(entity, :attributes)
              end
            end

            describe 'with attribute: nil' do
              let(:expected) { { introduction: nil } }

              it 'should update the attributes' do
                expect { entity.assign_attributes(introduction: nil) }
                  .to change(entity, :attributes)
                  .to be == expected
              end
            end

            describe 'with attribute: value' do
              let(:introduction) do
                'It was the best of times, it was the worst of times.'
              end
              let(:expected) { { introduction: introduction } }

              it 'should update the attributes' do
                expect { entity.assign_attributes(introduction: introduction) }
                  .to change(entity, :attributes)
                  .to be == expected
              end
            end
          end
        end

        wrap_context 'when the entity class has a read-only attribute' do
          describe 'with an empty hash' do
            it 'should not change the attributes' do
              expect { entity.assign_attributes({}) }
                .not_to change(entity, :attributes)
            end
          end

          describe 'with attribute: nil' do
            it 'should not change the attributes' do
              expect { entity.assign_attributes(isbn: nil) }
                .not_to change(entity, :attributes)
            end
          end

          describe 'with attribute: value' do
            it 'should not change the attributes' do
              expect { entity.assign_attributes(isbn: '123-4-56-789012-3') }
                .not_to change(entity, :attributes)
            end
          end

          context 'when the entity is initialized with attributes' do
            let(:custom_isbn) { '978-3-16-148410-0' }
            let(:initial_attributes) do
              super().merge(isbn: custom_isbn)
            end

            describe 'with an empty hash' do
              it 'should not change the attributes' do
                expect { entity.assign_attributes({}) }
                  .not_to change(entity, :attributes)
              end
            end

            describe 'with attribute: nil' do
              it 'should not change the attributes' do
                expect { entity.assign_attributes(isbn: nil) }
                  .not_to change(entity, :attributes)
              end
            end

            describe 'with attribute: value' do
              it 'should not change the attributes' do
                expect { entity.assign_attributes(isbn: '123-4-56-789012-3') }
                  .not_to change(entity, :attributes)
              end
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

      describe '#attributes' do
        let(:defined_attributes) { defined?(super()) ? super() : [] }
        let(:expected_attributes) do
          defined_attributes
            .each
            .with_object({}) do |name, hsh|
              hsh[name] = nil
            end
            .merge(initial_attributes)
        end

        it { expect(entity).to respond_to(:attributes).with(0).arguments }

        it { expect(entity.attributes).to be == expected_attributes }

        wrap_context 'when the entity class has many attributes' do
          it { expect(entity.attributes).to be == expected_attributes }

          context 'when the entity is initialized with attributes' do
            let(:initial_attributes) do
              super().merge(
                title:            'The Once And Future King',
                publication_date: Date.new(1958, 1, 1)
              )
            end

            it { expect(entity.attributes).to be == expected_attributes }
          end
        end

        wrap_context \
          'when the entity class has an attribute with default block' \
        do
          let(:expected_attributes) do
            super().merge(series_index: series_counter.index)
          end

          it { expect(entity.attributes).to be == expected_attributes }
        end

        wrap_context \
          'when the entity class has an attribute with default value' \
        do
          let(:expected_attributes) do
            super().merge(introduction: default_introduction)
          end

          it { expect(entity.attributes).to be == expected_attributes }

          context 'when the attribute is initialized with nil' do
            let(:initial_attributes) do
              super().merge(introduction: nil)
            end

            it { expect(entity.attributes).to be == expected_attributes }
          end

          context 'when the attribute is initialized with a value' do
            let(:custom_introduction) do
              'In a hole in the ground there lived a hobbit.'
            end
            let(:initial_attributes) do
              super().merge(introduction: custom_introduction)
            end
            let(:expected_attributes) do
              super().merge(introduction: custom_introduction)
            end

            it { expect(entity.attributes).to be == expected_attributes }
          end
        end
      end

      describe '#attributes=' do
        it { expect(entity).to respond_to(:attributes=).with(1).arguments }

        describe 'with nil' do
          let(:error_message) do
            'expected attributes to be a Hash, but was nil'
          end

          it 'should raise an error' do
            expect { entity.attributes = nil }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an empty hash' do
          it 'should not change the attributes' do
            expect { entity.attributes = {} }
              .not_to change(entity, :attributes)
          end
        end

        describe 'with a hash with invalid string keys' do
          let(:mystery) do
            'Princess Pink, in the Playroom, with the Squeaky Mallet'
          end
          let(:error_message) { 'invalid attribute "mystery"' }
          let(:attributes)    { { 'mystery' => mystery } }

          it 'should raise an error' do
            expect { entity.attributes = attributes }
              .to raise_error ArgumentError, error_message
          end

          # rubocop:disable Lint/HandleExceptions
          # rubocop:disable RSpec/ExampleLength
          it 'should not change the attributes' do
            expect do
              begin
                entity.attributes = attributes
              rescue ArgumentError
              end
            end
              .not_to change(entity, :attributes)
          end
          # rubocop:enable Lint/HandleExceptions
          # rubocop:enable RSpec/ExampleLength
        end

        describe 'with a hash with invalid symbol keys' do
          let(:mystery) do
            'Princess Pink, in the Playroom, with the Squeaky Mallet'
          end
          let(:error_message) { 'invalid attribute :mystery' }
          let(:attributes)    { { mystery: mystery } }

          it 'should raise an error' do
            expect { entity.attributes = attributes }
              .to raise_error ArgumentError, error_message
          end

          # rubocop:disable Lint/HandleExceptions
          # rubocop:disable RSpec/ExampleLength
          it 'should not change the attributes' do
            expect do
              begin
                entity.attributes = attributes
              rescue ArgumentError
              end
            end
              .not_to change(entity, :attributes)
          end
          # rubocop:enable Lint/HandleExceptions
          # rubocop:enable RSpec/ExampleLength
        end

        wrap_context 'when the entity class has many attributes' do
          describe 'with nil' do
            let(:error_message) do
              'expected attributes to be a Hash, but was nil'
            end

            it 'should raise an error' do
              expect { entity.attributes = nil }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with an empty hash' do
            it 'should not change the attributes' do
              expect { entity.attributes = {} }
                .not_to change(entity, :attributes)
            end
          end

          describe 'with a hash with invalid string keys' do
            let(:mystery) do
              'Princess Pink, in the Playroom, with the Squeaky Mallet'
            end
            let(:error_message) { 'invalid attribute "mystery"' }
            let(:attributes)    { { 'mystery' => mystery } }

            it 'should raise an error' do
              expect { entity.attributes = attributes }
                .to raise_error ArgumentError, error_message
            end

            # rubocop:disable Lint/HandleExceptions
            # rubocop:disable RSpec/ExampleLength
            it 'should not change the attributes' do
              expect do
                begin
                  entity.attributes = attributes
                rescue ArgumentError
                end
              end
                .not_to change(entity, :attributes)
            end
            # rubocop:enable Lint/HandleExceptions
            # rubocop:enable RSpec/ExampleLength
          end

          describe 'with a hash with invalid symbol keys' do
            let(:mystery) do
              'Princess Pink, in the Playroom, with the Squeaky Mallet'
            end
            let(:error_message) { 'invalid attribute :mystery' }
            let(:attributes) { { mystery: mystery } }

            it 'should raise an error' do
              expect { entity.attributes = attributes }
                .to raise_error ArgumentError, error_message
            end

            # rubocop:disable Lint/HandleExceptions
            # rubocop:disable RSpec/ExampleLength
            it 'should not change the attributes' do
              expect do
                begin
                  entity.attributes = attributes
                rescue ArgumentError
                end
              end
                .not_to change(entity, :attributes)
            end
            # rubocop:enable Lint/HandleExceptions
            # rubocop:enable RSpec/ExampleLength
          end

          describe 'with a hash with valid string keys' do
            let(:attributes) do
              {
                'title'      => 'The Lay of Beleriand',
                'page_count' => 500
              }
            end
            let(:expected) do
              {
                title:            attributes['title'],
                page_count:       attributes['page_count'],
                publication_date: nil
              }
            end

            it 'should set the attributes' do
              expect { entity.attributes = attributes }
                .to change(entity, :attributes)
                .to be == expected
            end
          end

          describe 'with a hash with valid symbol keys' do
            let(:attributes) do
              {
                title:      'The Lay of Beleriand',
                page_count: 500
              }
            end
            let(:expected) do
              {
                title:            attributes[:title],
                page_count:       attributes[:page_count],
                publication_date: nil
              }
            end

            it 'should set the attributes' do
              expect { entity.attributes = attributes }
                .to change(entity, :attributes)
                .to be == expected
            end
          end

          context 'when the entity is initialized with attributes' do
            let(:initial_attributes) do
              super().merge(
                title:            'The Once And Future King',
                publication_date: Date.new(1958, 1, 1)
              )
            end

            describe 'with an empty hash' do
              let(:expected) do
                {
                  title:            nil,
                  page_count:       nil,
                  publication_date: nil
                }
              end

              it 'should clear the attributes' do
                expect { entity.attributes = {} }
                  .to change(entity, :attributes)
                  .to be == expected
              end
            end

            describe 'with a hash with invalid string keys' do
              let(:mystery) do
                'Princess Pink, in the Playroom, with the Squeaky Mallet'
              end
              let(:error_message) { 'invalid attribute "mystery"' }
              let(:attributes)    { { 'mystery' => mystery } }

              it 'should raise an error' do
                expect { entity.attributes = attributes }
                  .to raise_error ArgumentError, error_message
              end

              # rubocop:disable Lint/HandleExceptions
              # rubocop:disable RSpec/ExampleLength
              it 'should not change the attributes' do
                expect do
                  begin
                    entity.attributes = attributes
                  rescue ArgumentError
                  end
                end
                  .not_to change(entity, :attributes)
              end
              # rubocop:enable Lint/HandleExceptions
              # rubocop:enable RSpec/ExampleLength
            end

            describe 'with a hash with invalid symbol keys' do
              let(:mystery) do
                'Princess Pink, in the Playroom, with the Squeaky Mallet'
              end
              let(:error_message) { 'invalid attribute :mystery' }
              let(:attributes)    { { mystery: mystery } }

              it 'should raise an error' do
                expect { entity.attributes = attributes }
                  .to raise_error ArgumentError, error_message
              end

              # rubocop:disable Lint/HandleExceptions
              # rubocop:disable RSpec/ExampleLength
              it 'should not change the attributes' do
                expect do
                  begin
                    entity.attributes = attributes
                  rescue ArgumentError
                  end
                end
                  .not_to change(entity, :attributes)
              end
              # rubocop:enable Lint/HandleExceptions
              # rubocop:enable RSpec/ExampleLength
            end

            describe 'with a hash with valid string keys' do
              let(:attributes) do
                {
                  'title'      => 'The Lay of Beleriand',
                  'page_count' => 500
                }
              end
              let(:expected) do
                {
                  title:            attributes['title'],
                  page_count:       attributes['page_count'],
                  publication_date: nil
                }
              end

              it 'should set the attributes' do
                expect { entity.attributes = attributes }
                  .to change(entity, :attributes)
                  .to be == expected
              end
            end

            describe 'with a hash with valid symbol keys' do
              let(:attributes) do
                {
                  title:      'The Lay of Beleriand',
                  page_count: 500
                }
              end
              let(:expected) do
                {
                  title:            attributes[:title],
                  page_count:       attributes[:page_count],
                  publication_date: nil
                }
              end

              it 'should set the attributes' do
                expect { entity.attributes = attributes }
                  .to change(entity, :attributes)
                  .to be == expected
              end
            end
          end
        end

        wrap_context \
          'when the entity class has an attribute with default value' \
        do
          describe 'with an empty hash' do
            let(:expected) { { introduction: nil } }

            it 'should update the attributes' do
              expect { entity.attributes = {} }
                .to change(entity, :attributes)
                .to be == expected
            end
          end

          describe 'with attribute: nil' do
            let(:expected) { { introduction: nil } }

            it 'should update the attributes' do
              expect { entity.attributes = { introduction: nil } }
                .to change(entity, :attributes)
                .to be == expected
            end
          end

          describe 'with attribute: value' do
            let(:introduction) do
              'It was the best of times, it was the worst of times.'
            end
            let(:expected) { { introduction: introduction } }

            it 'should update the attributes' do
              expect { entity.attributes = { introduction: introduction } }
                .to change(entity, :attributes)
                .to be == expected
            end
          end

          context 'when the entity is initialized with attributes' do
            let(:custom_introduction) do
              'In a hole in the ground there lived a hobbit.'
            end
            let(:initial_attributes) do
              super().merge(introduction: custom_introduction)
            end

            describe 'with an empty hash' do
              let(:expected) { { introduction: nil } }

              it 'should update the attributes' do
                expect { entity.attributes = {} }
                  .to change(entity, :attributes)
                  .to be == expected
              end
            end

            describe 'with attribute: nil' do
              let(:expected) { { introduction: nil } }

              it 'should update the attributes' do
                expect { entity.attributes = { introduction: nil } }
                  .to change(entity, :attributes)
                  .to be == expected
              end
            end

            describe 'with attribute: value' do
              let(:introduction) do
                'It was the best of times, it was the worst of times.'
              end
              let(:expected) { { introduction: introduction } }

              it 'should update the attributes' do
                expect { entity.attributes = { introduction: introduction } }
                  .to change(entity, :attributes)
                  .to be == expected
              end
            end
          end
        end

        wrap_context 'when the entity class has a read-only attribute' do
          describe 'with an empty hash' do
            it 'should not change the attributes' do
              expect { entity.attributes = {} }
                .not_to change(entity, :attributes)
            end
          end

          describe 'with attribute: nil' do
            it 'should not change the attributes' do
              expect { entity.attributes = { isbn: nil } }
                .not_to change(entity, :attributes)
            end
          end

          describe 'with attribute: value' do
            let(:isbn)     { '123-4-56-789012-3' }
            let(:expected) { { isbn: isbn } }

            it 'should update the attributes' do
              expect { entity.attributes = { isbn: isbn } }
                .to change(entity, :attributes)
                .to be == expected
            end
          end

          context 'when the entity is initialized with attributes' do
            let(:custom_isbn) { '978-3-16-148410-0' }
            let(:initial_attributes) do
              super().merge(isbn: custom_isbn)
            end

            describe 'with an empty hash' do
              let(:expected) { { isbn: nil } }

              it 'should update the attributes' do
                expect { entity.attributes = {} }
                  .to change(entity, :attributes)
                  .to be == expected
              end
            end

            describe 'with attribute: nil' do
              let(:expected) { { isbn: nil } }

              it 'should update the attributes' do
                expect { entity.attributes = {} }
                  .to change(entity, :attributes)
                  .to be == expected
              end
            end

            describe 'with attribute: value' do
              let(:isbn)     { '123-4-56-789012-3' }
              let(:expected) { { isbn: isbn } }

              it 'should update the attributes' do
                expect { entity.attributes = { isbn: isbn } }
                  .to change(entity, :attributes)
                  .to be == expected
              end
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

      describe '#inspect' do
        let(:attributes) do
          entity_class
            .attributes
            .map do |name, _metadata|
              ' ' + name.to_s + ': ' + entity.send(name).inspect
            end
            .join ','
        end
        let(:expected) { "#<#{entity_class.name}#{attributes}>" }

        it { expect(entity.inspect).to be == expected }

        wrap_context 'when the entity class has many attributes' do
          it { expect(entity.inspect).to be == expected }

          context 'when the entity is initialized with attributes' do
            let(:initial_attributes) do
              super().merge(
                title:            'The Once And Future King',
                publication_date: Date.new(1958, 1, 1)
              )
            end

            it { expect(entity.inspect).to be == expected }
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
    end
  end
end
