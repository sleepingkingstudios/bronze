# spec/bronze/entities/transforms/entity_transform_spec.rb

require 'bronze/entities/entity'
require 'bronze/entities/transforms/entity_transform'

RSpec.describe Bronze::Entities::Transforms::EntityTransform do
  let(:entity_class) do
    Class.new(Bronze::Entities::Entity) do
      attribute :title,   String
      attribute :author,  String
      attribute :preface, String
    end # class
  end # let
  let(:instance) { described_class.new entity_class }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#denormalize' do
    let(:expected) do
      entity = entity_class.new

      entity_class.attributes.each do |attr_name, _|
        entity.send(:"#{attr_name}=", attributes[attr_name])
      end # each

      entity
    end # let

    it { expect(instance).to respond_to(:denormalize).with(1).argument }

    describe 'with nil' do
      it 'should return an empty entity' do
        entity = instance.denormalize nil

        expect(entity).to be_a entity_class

        entity_class.attributes.each do |attr_name, _|
          next if attr_name == :id

          expect(entity.send attr_name).to be nil
        end # each
      end # it
    end # describe

    describe 'with an empty attributes hash' do
      it 'should return an empty entity' do
        entity = instance.denormalize({})

        expect(entity).to be_a entity_class

        entity_class.attributes.each do |attr_name, _|
          next if attr_name == :id

          expect(entity.send attr_name).to be nil
        end # each
      end # it
    end # describe

    describe 'with an attributes hash' do
      let(:attributes) do
        { :id => '0', :title => 'The Art of War', :author => 'Sun Tzu' }
      end # let

      it { expect(instance.denormalize attributes).to be == expected }
    end # describe
  end # describe

  describe '#entity_class' do
    include_examples 'should have reader', :entity_class, ->() { entity_class }
  end # describe

  describe '#normalize' do
    let(:expected) do
      entity_class.attributes.each_key.with_object({}) do |attr_name, hsh|
        hsh[attr_name] = entity.send(attr_name)
      end # each
    end # let

    it { expect(instance).to respond_to(:normalize).with(1).argument }

    describe 'with nil' do
      let(:entity) { entity_class.new }

      it { expect(instance.normalize nil).to be == {} }
    end # describe

    describe 'with an entity with empty attributes' do
      let(:entity) { entity_class.new }

      it { expect(instance.normalize entity).to be == expected }
    end # describe

    describe 'with an entity with set attributes' do
      let(:entity) do
        entity_class.new :title => 'The Art of War', :author => 'Sun Tzu'
      end # let

      it { expect(instance.normalize entity).to be == expected }
    end # describe
  end # describe
end # describe