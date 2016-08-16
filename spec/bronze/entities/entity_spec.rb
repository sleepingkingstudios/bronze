# spec/bronze/entities/entity_spec.rb

require 'bronze/entities/entity'

require 'bronze/entities/attributes/examples'

RSpec.describe Bronze::Entities::Entity do
  include Spec::Entities::Attributes::AttributesExamples

  shared_context 'when an entity class is defined' do
    let(:described_class) { Class.new(super()) }
  end # context

  shared_context 'when an entity class is defined with attributes' do
    let(:described_class) do
      Class.new(super()) do
        attribute :title,            String
        attribute :page_count,       Integer
        attribute :publication_date, Date
      end # class
    end # let
  end # shared_context

  let(:attributes) { {} }
  let(:instance)   { described_class.new(attributes) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end # describe

  describe '::attribute' do
    shared_context 'when the attribute has been defined' do
      let!(:metadata) do
        described_class.attribute attribute_name, attribute_type, attribute_opts
      end # let!
    end # shared_context

    it 'should respond to the method' do
      expect(described_class).to respond_to(:attribute).with(2..3).arguments
    end # it

    wrap_context 'when an entity class is defined' do
      describe 'with a valid attribute name and attribute type' do
        let(:attribute_name) { :title }
        let(:attribute_type) { String }
        let(:attribute_opts) { {} }
        let(:attributes)     { super().merge :title => 'The Ramayana' }

        it 'should set and return the metadata' do
          metadata = described_class.attribute attribute_name, attribute_type

          expect(metadata).to be_a Bronze::Entities::Attributes::Metadata
          expect(metadata.attribute_name).to be == attribute_name
          expect(metadata.attribute_type).to be == attribute_type

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
    end # wrap_context
  end # describe

  describe '::attributes' do
    it 'should define the reader' do
      expect(described_class).
        to have_reader(:attributes).
        with_value(an_instance_of Hash)
    end # it

    it 'should return a frozen copy of the attributes hash' do
      metadata =
        Bronze::Entities::Attributes::Metadata.new(:malicious, Object, {})

      expect { described_class.attributes[:bogus] = metadata }.
        to raise_error(RuntimeError)

      expect(described_class.attributes.keys).to contain_exactly :id
    end # it

    wrap_context 'when an entity class is defined with attributes' do
      let(:expected) { [:id, :title, :page_count, :publication_date] }

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
          expect(described_class.attributes.keys).to contain_exactly(*expected)

          expect(subclass.attributes.keys).
            to contain_exactly(*expected, :endorsements)
        end # it
      end # context
    end # wrap_context
  end # describe

  describe '#assign' do
    it { expect(instance).to respond_to(:assign).with(1).argument }

    it 'should not update the attributes' do
      expect { instance.assign(:malicious => :value) }.
        not_to change(instance, :attributes)
    end # it

    wrap_context 'when an entity class is defined with attributes' do
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
        hsh.update :id => instance.id
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

    wrap_context 'when an entity class is defined with attributes' do
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

    wrap_context 'when an entity class is defined with attributes' do
      let(:expected) do
        {
          :id               => an_instance_of(String),
          :title            => nil,
          :page_count       => nil,
          :publication_date => nil
        } # end hash
      end # let

      it 'should return the attributes' do
        attributes = instance.attributes

        expect(attributes).to be_a Hash
        expect(attributes.keys).to be == expected.keys
        expect(attributes.fetch :id).to match expected.delete(:id)

        expected.each_key { |key| expect(attributes.fetch key).to be nil }
      end # it
    end # wrap_context
  end # describe

  describe '#attributes=' do
    it { expect(instance).to have_writer(:attributes=) }

    it 'should not update the attributes' do
      expect { instance.attributes = { :malicious => :value } }.
        not_to change(instance, :attributes)
    end # it

    wrap_context 'when an entity class is defined with attributes' do
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
        hsh.update :id => instance.id
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

  describe '#id' do
    include_examples 'should define attribute',
      :id,
      Bronze::Entities::Ulid,
      :read_only => true

    it 'should generate a ULID' do
      ulid = instance.id

      expect(ulid).to be_a String
      expect(ulid.length).to be == 26

      chars = ulid.split('').uniq
      chars.each do |char|
        expect(Bronze::Entities::Ulid::ENCODING).to include char
      end # each
    end # it

    it 'should be consistent' do
      ids = Array.new(3) { instance.id }.uniq

      expect(ids.length).to be 1
    end # it
  end # describe
end # describe
