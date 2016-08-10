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
      before(:example) do
        described_class.attribute attribute_name, attribute_type
      end # before example
    end # shared_context

    it 'should respond to the method' do
      expect(described_class).to respond_to(:attribute).with(2..3).arguments
    end # it

    wrap_context 'when an entity class is defined' do
      describe 'with a valid attribute name and attribute type' do
        let(:attribute_name) { :title }
        let(:attribute_type) { String }
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
              expect(instance.send attribute_name).
                to be == attributes[attribute_name].inspect

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
    it { expect(described_class).to have_reader(:attributes).with_value({}) }

    it 'should return a frozen copy of the attributes hash' do
      metadata = Bronze::Entities::Attributes::Metadata.new(:malicious, Object)

      expect { described_class.attributes[:bogus] = metadata }.
        to raise_error(RuntimeError)

      expect(described_class.attributes).to be == {}
    end # it

    wrap_context 'when an entity class is defined with attributes' do
      let(:expected) { [:title, :page_count, :publication_date] }

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
    it { expect(instance).to have_reader(:attributes).with_value({}) }

    wrap_context 'when an entity class is defined with attributes' do
      let(:expected) do
        { :title => nil, :page_count => nil, :publication_date => nil }
      end # let

      it { expect(instance.attributes).to be == expected }
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
end # describe
