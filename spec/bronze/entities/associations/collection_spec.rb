# spec/bronze/entities/associations/collection_spec.rb

require 'bronze/entities/associations/associations_examples'
require 'bronze/entities/associations/collection'
require 'bronze/entities/associations/metadata/has_many_metadata'
require 'support/example_entity'

RSpec.describe Bronze::Entities::Associations::Collection do
  include Spec::Entities::Associations::AssociationsExamples

  shared_examples 'should add the entity to the collection' do
    include_examples 'should update the association state'
    include_examples 'should update the collection state'

    describe 'with nil' do
      let(:new_value) { nil }

      include_examples 'should raise a validation error'

      include_examples 'should not change the collection count'

      include_examples 'should not change the collection items'
    end # describe

    describe 'with an object' do
      let(:new_value) { Object.new }

      include_examples 'should raise a validation error'

      include_examples 'should not change the collection count'

      include_examples 'should not change the collection items'
    end # describe

    describe 'with an entity' do
      let(:other_class) { Class.new(Bronze::Entities::Entity) }
      let(:new_value)   { other_class.new }

      include_examples 'should raise a validation error'

      include_examples 'should not change the collection count'

      include_examples 'should not change the collection items'
    end # describe

    describe 'with an instance of the association class' do
      let(:new_value) { association_class.new }

      include_examples 'should increment the collection count'

      include_examples 'should add the entity to the collection items'

      include_examples 'should change the new value inverse foreign key'

      include_examples 'should change the new value inverse value'
    end # describe

    wrap_context 'when the collection has many entities' do
      describe 'with nil' do
        let(:new_value) { nil }

        include_examples 'should raise a validation error'

        include_examples 'should not change the collection count'

        include_examples 'should not change the collection items'
      end # describe

      describe 'with an object' do
        let(:new_value) { Object.new }

        include_examples 'should raise a validation error'

        include_examples 'should not change the collection count'

        include_examples 'should not change the collection items'
      end # describe

      describe 'with an entity' do
        let(:other_class) { Class.new(Bronze::Entities::Entity) }
        let(:new_value)   { other_class.new }

        include_examples 'should raise a validation error'

        include_examples 'should not change the collection count'

        include_examples 'should not change the collection items'
      end # describe

      describe 'with an instance of the association class' do
        let(:new_value) { association_class.new }

        include_examples 'should increment the collection count'

        include_examples 'should add the entity to the collection items'

        include_examples 'should change the new value inverse foreign key'

        include_examples 'should change the new value inverse value'
      end # describe
    end # wrap_context
  end # shared_examples

  shared_examples 'should remove the entity from the collection' do
    include_examples 'should update the association state'
    include_examples 'should update the collection state'

    describe 'with nil' do
      let(:new_value) { nil }

      include_examples 'should raise a validation error'

      include_examples 'should not change the collection count'

      include_examples 'should not change the collection items'
    end # describe

    describe 'with an object' do
      let(:new_value) { Object.new }

      include_examples 'should raise a validation error'

      include_examples 'should not change the collection count'

      include_examples 'should not change the collection items'
    end # describe

    describe 'with an entity' do
      let(:other_class) { Class.new(Bronze::Entities::Entity) }
      let(:new_value)   { other_class.new }

      include_examples 'should raise a validation error'

      include_examples 'should not change the collection count'

      include_examples 'should not change the collection items'
    end # describe

    describe 'with an instance of the association class' do
      let(:new_value) { association_class.new }

      include_examples 'should return nil'

      include_examples 'should not change the collection count'

      include_examples 'should not change the collection items'
    end # describe

    describe 'with a primary key' do
      let(:new_value) { 'NOT4PRIMARYKEY' }

      include_examples 'should return nil'

      include_examples 'should not change the collection count'

      include_examples 'should not change the collection items'
    end # describe

    wrap_context 'when the collection has many entities' do
      describe 'with nil' do
        let(:new_value) { nil }

        include_examples 'should raise a validation error'

        include_examples 'should not change the collection count'

        include_examples 'should not change the collection items'
      end # describe

      describe 'with an object' do
        let(:new_value) { Object.new }

        include_examples 'should raise a validation error'

        include_examples 'should not change the collection count'

        include_examples 'should not change the collection items'
      end # describe

      describe 'with an entity' do
        let(:other_class) { Class.new(Bronze::Entities::Entity) }
        let(:new_value)   { other_class.new }

        include_examples 'should raise a validation error'

        include_examples 'should not change the collection count'

        include_examples 'should not change the collection items'
      end # describe

      describe 'with an instance of the association class' do
        let(:new_value) { association_class.new }

        include_examples 'should return nil'

        include_examples 'should not change the collection count'

        include_examples 'should not change the collection items'
      end # describe

      describe 'with a primary key' do
        let(:new_value) { 'NOT4PRIMARYKEY' }

        include_examples 'should return nil'

        include_examples 'should not change the collection count'

        include_examples 'should not change the collection items'
      end # describe

      describe 'with an entity from the collection' do
        let(:new_value)   { prior_values.first }
        let(:prior_value) { new_value }

        include_examples 'should return the new value'

        include_examples 'should decrement the collection count'

        include_examples 'should remove the entity from the collection items'

        include_examples 'should clear the prior value inverse foreign key'

        include_examples 'should clear the prior value inverse value'
      end # describe

      describe 'with the primary key of an entity from the collection' do
        let(:new_value)   { prior_values.first.id }
        let(:prior_value) { prior_values.first }

        include_examples 'should return the new value'

        include_examples 'should decrement the collection count'

        include_examples 'should remove the entity from the collection items'

        include_examples 'should clear the prior value inverse foreign key'

        include_examples 'should clear the prior value inverse value'
      end # describe
    end # wrap_context
  end # shared_examples

  shared_examples 'should clear the collection' do
    include_examples 'should update the association state'
    include_examples 'should update the collection state'

    include_examples 'should not change the collection count'

    include_examples 'should not change the collection items'

    wrap_context 'when the collection has many entities' do
      include_examples 'should set the collection count to zero'

      include_examples 'should clear the collection items'

      include_examples 'should clear the prior values inverse foreign keys'

      include_examples 'should clear the prior values inverse values'
    end # wrap_context
  end # shared_examples

  mock_class Spec, :Author, :base_class => Spec::ExampleEntity
  mock_class Spec, :Book,   :base_class => Spec::ExampleEntity do |klass|
    klass.references_one :author, :class_name => 'Spec::Author'
  end # mock_class

  let(:metadata) do
    klass = Bronze::Entities::Associations::Metadata::HasManyMetadata
    klass.new(
      entity_class,
      :books,
      :class_name => 'Spec::Book',
      :inverse    => :author
    ) # end new
  end # let
  let(:association_class) do
    Spec::Book
  end # let
  let(:entity_class) { Spec::Author }
  let(:entity)       { entity_class.new }
  let(:params)       { [entity, metadata] }
  let(:instance)     { described_class.new(*params) }
  let(:collection)   { instance }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(2..3).arguments }
  end # describe

  describe '#<<' do
    let(:assoc_name)          { metadata.name }
    let(:inverse_name)        { :author }
    let(:inverse_foreign_key) { :author_id }

    define_method :set_value do |value|
      instance << value
    end # method set_value

    it { expect(instance).to respond_to(:<<).with(1).argument }

    include_examples 'should add the entity to the collection'

    describe 'with an instance of the association class' do
      let(:new_value) { association_class.new }

      it 'should return the collection' do
        expect(set_value new_value).to be instance
      end # it
    end # describe

    wrap_context 'when the collection has many entities' do
      describe 'with an instance of the association class' do
        let(:new_value) { association_class.new }

        it 'should return the collection' do
          expect(set_value new_value).to be instance
        end # it
      end # describe
    end # wrap_context
  end # describe

  describe '#==' do
    it { expect(instance).to respond_to(:==).with(1).argument }

    # rubocop:disable Style/NilComparison
    describe 'with nil' do
      it { expect(instance == nil).to be false }
    end # describe
    # rubocop:enable Style/NilComparison

    describe 'with an object' do
      it { expect(instance == Object.new).to be false }
    end # describe

    describe 'with an empty array' do
      it { expect(instance == []).to be true }
    end # describe

    describe 'with an array with other entities' do
      let(:other_entities) { Array.new(3) { entity_class.new } }

      it { expect(instance == other_entities).to be false }
    end # describe

    describe 'with an empty collection' do
      let(:collection) { described_class.new entity, metadata }

      it { expect(instance == collection).to be true }
    end # describe

    describe 'with a collection with other entities' do
      let(:other_entities) { Array.new(3) { entity_class.new } }
      let(:collection) do
        described_class.new entity, metadata, other_entities
      end # let

      it { expect(instance == other_entities).to be false }
    end # describe

    wrap_context 'when the collection has many entities' do
      # rubocop:disable Style/NilComparison
      describe 'with nil' do
        it { expect(instance == nil).to be false }
      end # describe
      # rubocop:enable Style/NilComparison

      describe 'with an object' do
        it { expect(instance == Object.new).to be false }
      end # describe

      describe 'with an empty array' do
        it { expect(instance == []).to be false }
      end # describe

      describe 'with an array with other entities' do
        let(:other_entities) { Array.new(3) { entity_class.new } }

        it { expect(instance == other_entities).to be false }
      end # describe

      describe 'with an array with the same entities' do
        it { expect(instance == prior_values).to be true }
      end # describe

      describe 'with an empty collection' do
        let(:other_collection) { described_class.new entity, metadata }

        it { expect(instance == other_collection).to be false }
      end # describe

      describe 'with a collection with other entities' do
        let(:other_entities) { Array.new(3) { entity_class.new } }
        let(:other_collection) do
          described_class.new entity, metadata, other_entities
        end # let

        it { expect(instance == other_collection).to be false }
      end # describe

      describe 'with a collection with the same entities' do
        let(:other_collection) do
          described_class.new entity, metadata, prior_values
        end # let

        it { expect(instance == other_collection).to be true }
      end # describe
    end # wrap_context
  end # describe

  describe '#add' do
    let(:assoc_name)          { metadata.name }
    let(:inverse_name)        { :author }
    let(:inverse_foreign_key) { :author_id }

    define_method :set_value do |value|
      instance.add value
    end # method set_value

    it { expect(instance).to respond_to(:add).with(1).argument }

    include_examples 'should add the entity to the collection'

    describe 'with an instance of the association class' do
      let(:new_value) { association_class.new }

      include_examples 'should return the new value'
    end # describe

    wrap_context 'when the collection has many entities' do
      describe 'with an instance of the association class' do
        let(:new_value) { association_class.new }

        include_examples 'should return the new value'
      end # describe
    end # wrap_context
  end # describe

  describe '#clear' do
    let(:assoc_name)          { metadata.name }
    let(:inverse_name)        { :author }
    let(:inverse_foreign_key) { :author_id }
    let(:new_value)           { nil }

    define_method :set_value do |_|
      instance.clear
    end # method set_value

    it { expect(instance).to respond_to(:clear).with(0).arguments }

    it { expect(instance.clear).to be instance }

    include_examples 'should clear the collection'

    wrap_context 'when the collection has many entities' do
      it { expect(instance.clear).to be instance }
    end # wrap_context
  end # describe

  describe '#count' do
    it { expect(instance).to respond_to(:count).with(0).arguments }

    it { expect(instance.count).to be 0 }

    wrap_context 'when the collection has many entities' do
      it { expect(instance.count).to be prior_values.count }
    end # wrap_context
  end # describe

  describe '#delete' do
    let(:assoc_name)          { metadata.name }
    let(:inverse_name)        { :author }
    let(:inverse_foreign_key) { :author_id }

    define_method :set_value do |value|
      instance.delete value
    end # method set_value

    it { expect(instance).to respond_to(:delete).with(1).argument }

    include_examples 'should remove the entity from the collection'
  end # describe

  describe '#each' do
    it { expect(instance).to respond_to(:each).with_a_block }

    it 'should not yield any items' do
      yielded = []

      instance.each { |item| yielded << item }

      expect(yielded).to be_empty
    end # it

    wrap_context 'when the collection has many entities' do
      it 'should yield each entity' do
        yielded = []

        instance.each { |item| yielded << item }

        expect(yielded).to be == prior_values
      end # it
    end # wrap_context
  end # describe

  describe '#empty?' do
    it { expect(instance).to respond_to(:empty?).with(0).arguments }

    it { expect(instance.empty?).to be true }

    wrap_context 'when the collection has many entities' do
      it { expect(instance.empty?).to be false }
    end # wrap_context
  end # describe

  describe '#entity' do
    include_examples 'should have reader', :entity, ->() { be == entity }
  end # describe

  describe '#map' do
    it { expect(instance).to respond_to(:map) }

    it 'should not yield any items' do
      mapped = instance.map { |item| item }

      expect(mapped).to be_empty
    end # it

    wrap_context 'when the collection has many entities' do
      it 'should yield each entity' do
        mapped = instance.map { |item| item }

        expect(mapped).to be == prior_values
      end # it
    end # wrap_context
  end # describe

  describe '#metadata' do
    include_examples 'should have reader', :metadata, ->() { be == metadata }
  end # describe

  describe '#to_a' do
    it { expect(instance).to respond_to(:to_a).with(0).arguments }

    it { expect(instance.to_a).to be == [] }

    it { expect(instance.to_a.frozen?).to be true }

    wrap_context 'when the collection has many entities' do
      it { expect(instance.to_a).to be == prior_values }
    end # wrap_context
  end # describe
end # describe
