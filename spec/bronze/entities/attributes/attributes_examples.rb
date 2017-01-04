# spec/bronze/entities/attributes/attributes_examples.rb

require 'bronze/entities/ulid'

module Spec::Entities
  module Attributes; end
end # module

module Spec::Entities::Attributes::AttributesExamples
  extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

  shared_context 'when attributes are defined for the class' do
    let(:described_class) do
      Class.new(super()) do
        attribute :title,            String
        attribute :page_count,       Integer
        attribute :publication_date, Date
      end # class
    end # let
  end # shared_context

  desc = 'should define attribute'
  shared_examples desc do |attr_name, _attr_type, attr_opts = {}|
    reader_name = attr_name
    writer_name = :"#{reader_name}="
    undefined   = Object.new.freeze

    describe "should define attribute :#{attr_name}" do
      let(:entity)         { defined?(super()) ? super() : instance }
      let(:expected_value) { defined?(super()) ? super() : undefined }
      let(:updated_value)  { defined?(super()) ? super() : undefined }

      describe "##{reader_name}" do
        it 'should define the reader' do
          if expected_value == undefined
            expect(entity).to have_reader(reader_name)
          else
            expect(entity).
              to have_reader(reader_name).
              with_value(expected_value)
          end # if-else
        end # it
      end # describe

      describe "##{writer_name}" do
        it 'should define the writer' do
          if attr_opts[:read_only]
            expect(entity).not_to respond_to(writer_name)

            expect(entity).to respond_to(writer_name, true).with(1).argument
          else
            expect(entity).to have_writer(writer_name)
          end # if-else

          unless updated_value == undefined
            expect { entity.send(writer_name, updated_value) }.
              to change(entity, reader_name).
              to be == updated_value
          end # if-else
        end # it
      end # describe
    end # describe
  end # shared_examples

  shared_examples 'should implement the Attributes methods' do
    describe '::KEY_DEFAULT' do
      it 'should define the constant' do
        expect(described_class).to have_constant :KEY_DEFAULT
      end # it

      it 'should generate new ULID objects' do
        default = described_class::KEY_DEFAULT

        expect(default).to be_a Proc

        first  = default.call
        second = default.call

        # rubocop:disable Style/CaseEquality
        expect(Bronze::Entities::Ulid).to be === first
        expect(Bronze::Entities::Ulid).to be === second
        # rubocop:enable Style/CaseEquality

        expect(second).to be > first
      end # it
    end # describe

    describe '::KEY_TYPE' do
      it 'should define the constant' do
        expect(described_class).to have_constant(:KEY_TYPE).with_value(String)
      end # it
    end # describe

    describe '::attribute' do
      shared_context 'when the attribute has been defined' do
        let!(:metadata) do
          described_class.attribute(
            attribute_name,
            attribute_type,
            attribute_opts
          ) # end attribute
        end # let!
      end # shared_context

      it 'should respond to the method' do
        expect(described_class).to respond_to(:attribute).with(2..3).arguments
      end # it

      describe 'with a valid attribute name and attribute type' do
        let(:attribute_name) { :title }
        let(:attribute_type) { String }
        let(:attribute_opts) { {} }
        let(:attributes)     { super().merge :title => 'The Ramayana' }
        let(:attribute_type_class) do
          Bronze::Entities::Attributes::AttributeType
        end # let

        it 'should set and return the metadata' do
          metadata = described_class.attribute attribute_name, attribute_type
          mt_class = Bronze::Entities::Attributes::AttributeMetadata

          expect(metadata).to be_a mt_class
          expect(metadata.attribute_name).to be == attribute_name
          expect(metadata.attribute_type).to be_a attribute_type_class
          expect(metadata.object_type).to be == attribute_type

          expect(described_class.attributes[attribute_name]).to be metadata
        end # it

        wrap_context 'when the attribute has been defined' do
          let(:expected_value) { attributes.fetch attribute_name }
          let(:updated_value)  { 'Planet Dreams' }

          include_examples 'should define attribute', :title

          describe 'with :default => lambda' do
            let(:default) do
              books_count = 0

              ->() { "Book #{books_count += 1}" }
            end # let
            let(:attributes)     { super().merge :title => nil }
            let(:attribute_opts) { super().merge :default => default }
            let(:expected)       { ['Book 1', 'Book 2', 'Book 3'] }

            it 'should set the title to the default value' do
              books = Array.new(3) { described_class.new(attributes) }

              expect(books.map(&:title)).to be == expected
            end # it
          end # describe

          describe 'with :default => value' do
            let(:attributes)     { super().merge :title => nil }
            let(:attribute_opts) { super().merge :default => 'Untitled Book' }

            it { expect(instance.title).to be == attribute_opts[:default] }

            context 'when a value is set' do
              let(:attributes) do
                super().merge :title => 'The Lay of Beleriand'
              end # let

              describe 'with nil' do
                it 'should set the value to the default' do
                  expect { instance.title = nil }.
                    to change(instance, :title).
                    to be == attribute_opts[:default]
                end # describe
              end # describe
            end # context
          end # describe

          describe 'with :read_only => true' do
            let(:attribute_opts) { super().merge :read_only => true }

            include_examples 'should define attribute',
              :title,
              String,
              :read_only => true
          end # describe

          context 'when the attribute methods are overwritten' do
            before(:example) do
              described_class.send :define_method,
                attribute_name,
                lambda {
                  value = super()

                  value.inspect
                } # end lambda

              described_class.send :define_method,
                "#{attribute_name}=",
                ->(value) { super(value * 2) }
            end # before example

            it 'should inherit from the base definition' do
              expected = (attributes[attribute_name] * 2).inspect

              expect(instance.send attribute_name).
                to be == expected

              expected = (updated_value * 2).inspect

              expect { instance.send "#{attribute_name}=", updated_value }.
                to change(instance, attribute_name).
                to be == expected
            end # it
          end # describe
        end # wrap_context
      end # describe
    end # describe

    describe '::attributes' do
      it 'should define the reader' do
        expect(described_class).
          to have_reader(:attributes).
          with_value(an_instance_of Hash)
      end # it

      it 'should return a frozen copy of the attributes hash' do
        metadata =
          Bronze::Entities::Attributes::AttributeMetadata.new(
            :malicious,
            Object,
            {}
          ) # end metadata

        expect { described_class.attributes[:bogus] = metadata }.
          to raise_error(RuntimeError)

        expect(described_class.attributes.keys).
          to contain_exactly(*defined_attributes.keys)
      end # it

      wrap_context 'when attributes are defined for the class' do
        let(:expected) do
          [*defined_attributes.keys, :title, :page_count, :publication_date]
        end # let

        it 'should return the attributes metadata' do
          expect(described_class.attributes.keys).to contain_exactly(*expected)
        end # it

        context 'when an entity subclass is defined' do
          let(:subclass) do
            Class.new(described_class) do
              attribute :endorsements, Array
            end # let
          end # let

          it 'should return the class and superclass attributes' do
            expect(described_class.attributes.keys).
              to contain_exactly(*expected)

            expect(subclass.attributes.keys).
              to contain_exactly(*expected, :endorsements)
          end # it
        end # context
      end # wrap_context
    end # describe

    describe '::foreign_key' do
      shared_context 'when the attribute has been defined' do
        let!(:metadata) do
          described_class.foreign_key(attribute_name)
        end # let!
      end # shared_context

      it 'should respond to the method' do
        expect(described_class).to respond_to(:foreign_key).with(1).arguments
      end # it

      describe 'with a valid attribute name' do
        let(:attribute_name) { :association_id }
        let(:attribute_type) { described_class::KEY_TYPE }
        let(:attributes) do
          super().merge :association_id => Bronze::Entities::Ulid.generate
        end # let
        let(:attribute_type_class) do
          Bronze::Entities::Attributes::AttributeType
        end # let

        it 'should set and return the metadata' do
          metadata = described_class.foreign_key attribute_name
          mt_class = Bronze::Entities::Attributes::AttributeMetadata

          expect(metadata).to be_a mt_class
          expect(metadata.attribute_name).to be == attribute_name
          expect(metadata.attribute_type).to be_a attribute_type_class
          expect(metadata.object_type).to be == attribute_type
          expect(metadata.foreign_key?).to be true

          expect(described_class.attributes[attribute_name]).to be metadata
        end # it

        wrap_context 'when the attribute has been defined' do
          let(:expected_value) { attributes.fetch attribute_name }
          let(:updated_value)  { Bronze::Entities::Ulid.generate }

          include_examples 'should define attribute', :association_id
        end # wrap_context
      end # describe
    end # describe

    describe '#==' do
      let(:attributes)       { { :title => 'The Illiad' } }
      let(:other_class)      { Class.new(described_class) }
      let(:other_attributes) { attributes }
      let(:other_instance)   { other_class.new(other_attributes) }

      include_context 'when attributes are defined for the class'

      # rubocop:disable Style/NilComparison
      describe 'with nil' do
        it { expect(instance == nil).to be false }
      end # describe
      # rubocop:enable Style/NilComparison

      describe 'with an object' do
        it { expect(instance == Object.new).to be false }
      end # describe

      describe 'with an attributes hash' do
        it { expect(instance == attributes).to be false }
      end # describe

      describe 'with an object with another class and the same attributes' do
        it { expect(instance == other_instance).to be false }
      end # describe

      describe 'with an object with the same class and different attributes' do
        let(:other_instance) { described_class.new(:title => 'The Odyssey') }

        it { expect(instance == other_instance).to be false }
      end # describe

      describe 'with an object with the same class and attributes' do
        let(:other_attributes) do
          super().tap do |hsh|
            defined_attributes.each_key do |attr_name|
              hsh[attr_name] = instance.send(attr_name)
            end # each
          end # tap
        end # let
        let(:other_instance) { described_class.new(other_attributes) }

        it { expect(instance == other_instance).to be true }
      end # describe

      # rubocop:disable Lint/UselessComparison
      describe 'with the object' do
        it { expect(instance == instance).to be true }
      end # describe
      # rubocop:enable Lint/UselessComparison
    end # describe

    describe '#assign' do
      it { expect(instance).to respond_to(:assign).with(1).argument }

      it { expect(instance).to alias_method(:assign).as(:assign_attributes) }

      it 'should not update the attributes' do
        expect { instance.assign(:malicious => :value) }.
          not_to change(instance, :attributes)
      end # it

      wrap_context 'when attributes are defined for the class' do
        let(:attributes) do
          {
            :title            => 'The Once And Future King',
            :publication_date => Date.new(1958, 1, 1)
          } # end hash
        end # let
        let(:values) do
          {
            :title      => 'The Mists of Avalon',
            :page_count => 450,
            :foreward   => 'Hic Iacet Arthurus, Rex Quondam, Rexque Futurus'
          } # end hash
        end # let
        let(:expected) do
          hsh = values.dup

          defined_attributes.each_key do |attr_name|
            hsh.update attr_name => instance.send(attr_name)
          end # each

          hsh.delete :foreward
          attributes.merge hsh
        end # let

        it 'should overwrite the attributes' do
          expect { instance.assign values }.
            to change(instance, :attributes).
            to be == expected
        end # it
      end # wrap_context
    end # describe

    describe '#attribute?' do
      it { expect(instance).to respond_to(:attribute?).with(1).argument }

      it { expect(instance.attribute? :title).to be false }

      wrap_context 'when attributes are defined for the class' do
        it { expect(instance.attribute? :title).to be true }

        it { expect(instance.attribute? 'title').to be true }

        it { expect(instance.attribute? :foreward).to be false }
      end # it
    end # describe

    describe '#attributes' do
      it 'should define the reader' do
        expect(instance).
          to have_reader(:attributes).
          with_value(an_instance_of Hash)
      end # it

      wrap_context 'when attributes are defined for the class' do
        let(:expected) do
          hsh = {
            :title            => nil,
            :page_count       => nil,
            :publication_date => nil
          } # end hash

          defined_attributes.each do |attr_name, attr_type|
            hsh.update attr_name => an_instance_of(attr_type)
          end # each

          hsh
        end # let

        it 'should return the attributes' do
          attributes = instance.attributes

          expect(attributes).to be_a Hash
          expect(attributes.keys).to contain_exactly(*expected.keys)

          defined_attributes.each_key do |attr_name|
            expect(attributes.fetch attr_name).
              to match expected.delete(attr_name)
          end # each

          expected.each do |key, value|
            expect(attributes.fetch key).to be == value
          end # each
        end # it
      end # wrap_context
    end # describe

    describe '#attributes=' do
      it { expect(instance).to have_writer(:attributes=) }

      it 'should not update the attributes' do
        expect { instance.attributes = { :malicious => :value } }.
          not_to change(instance, :attributes)
      end # it

      wrap_context 'when attributes are defined for the class' do
        let(:attributes) do
          {
            :title            => 'The Once And Future King',
            :publication_date => Date.new(1958, 1, 1)
          } # end hash
        end # let
        let(:values) do
          {
            :title      => 'The Mists of Avalon',
            :page_count => 450,
            :foreward   => 'Hic Iacet Arthurus, Rex Quondam, Rexque Futurus'
          } # end hash
        end # let
        let(:expected) do
          hsh = values.dup

          defined_attributes.each_key do |attr_name|
            hsh.update attr_name => instance.send(attr_name)
          end # each

          hsh.delete :foreward
          hsh.merge :publication_date => nil
        end # let

        it 'should overwrite the attributes' do
          expect { instance.attributes = values }.
            to change(instance, :attributes).
            to be == expected
        end # it
      end # wrap_context
    end # describe
  end # shared_examples
end # module
