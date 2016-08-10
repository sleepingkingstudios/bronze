# spec/bronze/entities/attributes/builder_spec.rb

require 'bronze/entities/attributes/builder'

require 'bronze/entities/attributes/examples'

RSpec.describe Bronze::Entities::Attributes::Builder do
  include Spec::Entities::Attributes::AttributesExamples

  let(:entity_class) do
    Class.new do
      def initialize
        @attributes = {}
      end # constructor
    end # class
  end # let
  let(:entity)   { entity_class.new }
  let(:instance) { described_class.new(entity_class) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#entity_class' do
    include_examples 'should have reader', :entity_class, ->() { entity_class }
  end # describe

  describe '#build' do
    let(:attribute_name) { :title }
    let(:attribute_type) { String }

    it { expect(instance).to respond_to(:build).with(2).arguments }

    it 'should validate the attribute name', :aggregate_failures do
      expect { instance.build nil, attribute_type }.
        to raise_error described_class::Error,
          "attribute name can't be blank"

      expect { instance.build '', attribute_type }.
        to raise_error described_class::Error,
          "attribute name can't be blank"

      expect { instance.build Object.new, attribute_type }.
        to raise_error described_class::Error,
          'attribute name must be a String or Symbol'
    end # it

    it 'should validate the attribute type', :aggregate_failures do
      expect { instance.build attribute_name, nil }.
        to raise_error described_class::Error,
          "attribute type can't be blank"

      expect { instance.build attribute_name, Object.new }.
        to raise_error described_class::Error,
          'attribute type must be a Class'
    end # it

    describe 'with a valid attribute name and attribute type' do
      let(:updated_value) { 'Dream of a Red Chamber' }

      before(:example) do
        instance.build attribute_name, attribute_type
      end # before example

      include_examples 'should define attribute', :title, String
    end # describe
  end # describe
end # describe
