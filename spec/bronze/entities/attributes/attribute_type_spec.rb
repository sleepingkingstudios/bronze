# spec/bronze/entities/attributes/attribute_type_spec.rb

require 'bronze/entities/attributes/attribute_type'

RSpec.describe Bronze::Entities::Attributes::AttributeType do
  let(:attribute_type) { Integer }
  let(:instance)       { described_class.new attribute_type }

  describe '#matches?' do
    it { expect(instance).to respond_to(:matches?).with(1).argument }

    describe 'with nil' do
      it { expect(instance.matches? nil).to be false }
    end # describe

    describe 'with an object of another class' do
      it { expect(instance.matches? 0.0).to be false }
    end # describe

    describe 'with an object of the specified class' do
      it { expect(instance.matches? 0).to be true }
    end # describe
  end # describe

  describe '#object_type' do
    include_examples 'should have reader', :object_type, ->() { attribute_type }
  end # describe
end # describe
