# spec/patina/operations/entities/persistence_operation_spec.rb

require 'bronze/transforms/identity_transform'

require 'patina/collections/simple'
require 'patina/operations/entities/persistence_operation'

require 'support/example_entity'

RSpec.describe Patina::Operations::Entities::PersistenceOperation do
  let(:described_class) do
    Class.new do
      include Patina::Operations::Entities::PersistenceOperation
    end # class
  end # let
  let(:repository)     { Patina::Collections::Simple::Repository.new }
  let(:resource_class) { Spec::ArchivedPeriodical }
  let(:instance)       { described_class.new repository, resource_class }

  options = { :base_class => Spec::ExampleEntity }
  example_class 'Spec::ArchivedPeriodical', options do |klass|
    klass.attribute :title,  String
    klass.attribute :volume, Integer
  end # example_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(2..3).arguments }
  end # describe

  describe '#collection' do
    it 'should define the private reader' do
      expect(instance).not_to respond_to(:collection)

      expect(instance).to respond_to(:collection, true).with(0).arguments

      collection = instance.send(:collection)

      expect(collection).
        to be_a Patina::Collections::Simple::Collection
      expect(collection.name).to be == 'spec-archived_periodicals'
      expect(collection.transform).to be == instance.send(:transform)
    end # it
  end # describe

  describe '#plural_resource_name' do
    it 'should define the private reader' do
      expect(instance).not_to respond_to(:plural_resource_name)

      expect(instance).
        to respond_to(:plural_resource_name, true).
        with(0).arguments

      expect(instance.send :plural_resource_name).
        to be == 'archived_periodicals'
    end # it
  end # describe

  describe '#repository' do
    include_examples 'should have reader', :repository, ->() { repository }
  end # describe

  describe '#resource_class' do
    include_examples 'should have reader',
      :resource_class,
      ->() { resource_class }
  end # describe

  describe '#resource_name' do
    it 'should define the private reader' do
      expect(instance).not_to respond_to(:resource_name)

      expect(instance).to respond_to(:resource_name, true).with(0).arguments

      expect(instance.send :resource_name).to be == 'archived_periodical'
    end # it
  end # describe

  describe '#transform' do
    it 'should define the private reader' do
      expect(instance).not_to respond_to(:transform)

      expect(instance).to respond_to(:transform, true).with(0).arguments

      transform = instance.send(:transform)

      expect(transform).
        to be_a Patina::Operations::Entities::Transforms::PersistenceTransform
      expect(transform.entity_class).to be resource_class
    end # it

    context 'when a transform is provided to the constructor' do
      let(:transform) { Bronze::Transforms::IdentityTransform.new }
      let(:instance) do
        described_class.new repository, resource_class, transform
      end # let

      it { expect(instance.send :transform).to be transform }
    end # context
  end # describe
end # describe
