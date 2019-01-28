# spec/patina/transforms/resource_transform_spec.rb

require 'bronze/entities/entity'

require 'patina/transforms/resource_transform'

require 'support/example_entity'

RSpec.describe Patina::Transforms::ResourceTransform do
  let(:entity_class) do
    Class.new(Spec::ExampleEntity) do
      attribute :title,   String
      attribute :author,  String
      attribute :preface, String
    end # class
  end # let
  let(:options)  { {} }
  let(:instance) { described_class.new entity_class, options }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class).
        to be_constructible.
        with(1).argument.
        and_arbitrary_keywords
    end # it
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

        expect(entity.attributes_changed?).to be false
        expect(entity.persisted?).to be true
      end # it
    end # describe

    describe 'with an empty attributes hash' do
      let(:attributes) { {} }

      it 'should return an empty entity' do
        entity = instance.denormalize(attributes)

        expect(entity).to be_a entity_class

        entity_class.attributes.each do |attr_name, _|
          next if attr_name == :id

          expect(entity.send attr_name).to be nil
        end # each

        expect(entity.attributes_changed?).to be false
        expect(entity.persisted?).to be true
      end # it
    end # describe

    describe 'with an attributes hash' do
      let(:attributes) do
        { :id => '0', :title => 'The Art of War', :author => 'Sun Tzu' }
      end # let

      it 'should return an entity with the specified attributes' do
        entity = instance.denormalize attributes

        expect(entity).to be == expected

        expect(entity.attributes_changed?).to be false
        expect(entity.persisted?).to be true
      end # it
    end # describe
  end # describe

  describe '#entity_class' do
    include_examples 'should have reader', :entity_class, ->() { entity_class }
  end # describe

  describe '#options' do
    include_examples 'should have reader', :options, {}
  end # describe

  describe '#normalize' do
    shared_examples 'should forward the options to the entity' do
      context 'when options are set for the transform' do
        let(:options) { { :permit => Symbol } }

        it 'should forward the options to the entity' do
          expect(entity).to receive(:normalize).with(options)

          instance.normalize entity
        end # it
      end # context
    end # shared_examples

    let(:expected) do
      entity_class.attributes.each_key.with_object({}) do |attr_name, hsh|
        hsh[attr_name.to_s] = entity.send(attr_name)
      end # each
    end # let

    it { expect(instance).to respond_to(:normalize).with(1).argument }

    describe 'with nil' do
      it { expect(instance.normalize nil).to be == {} }
    end # describe

    describe 'with an entity with empty attributes' do
      let(:entity) { entity_class.new }

      it { expect(instance.normalize entity).to be == expected }

      include_examples 'should forward the options to the entity'
    end # describe

    describe 'with an entity with set attributes' do
      let(:entity) do
        entity_class.new :title => 'The Art of War', :author => 'Sun Tzu'
      end # let

      it { expect(instance.normalize entity).to be == expected }

      include_examples 'should forward the options to the entity'
    end # describe
  end # describe
end # describe
