# spec/bronze/entities/transforms/transform_spec.rb

require 'bronze/entities/transforms/transform'

RSpec.describe Bronze::Entities::Transforms::Transform do
  let(:entity_class) { Struct.new(:id) }
  let(:instance)     { described_class.new entity_class }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#denormalize' do
    it { expect(instance).to respond_to(:denormalize).with(1).argument }

    it 'should raise an error' do
      expect { instance.denormalize Object.new }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :denormalize"
    end # it
  end # describe

  describe '#entity_class' do
    include_examples 'should have reader', :entity_class, ->() { entity_class }
  end # describe

  describe '#normalize' do
    it { expect(instance).to respond_to(:normalize).with(1).argument }

    it 'should raise an error' do
      expect { instance.normalize Object.new }.
        to raise_error described_class::NotImplementedError,
          "#{described_class.name} does not implement :normalize"
    end # it
  end # describe
end # describe
