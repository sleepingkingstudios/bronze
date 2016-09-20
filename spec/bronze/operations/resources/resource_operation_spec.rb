# spec/bronze/operations/resources/resource_operation_spec.rb

require 'bronze/collections/reference/collection'
require 'bronze/collections/reference/repository'
require 'bronze/operations/operation'
require 'bronze/operations/resources/resource_operation'

RSpec.describe Bronze::Operations::Resources::ResourceOperation do
  let(:resource_class) do
    Class.new do
      def self.name
        'Publications::ArchivedPeriodical'
      end # class method name
    end # class
  end # let
  let(:described_class) { Spec::ResourceOperation }
  let(:repository)      { Bronze::Collections::Reference::Repository.new }
  let(:instance)        { described_class.new repository }

  mock_class Spec, :ResourceOperation do |klass|
    klass.send :include, Bronze::Operations::Resources::ResourceOperation

    klass.send :resource_class=, resource_class
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '::[]' do
    let(:resource_class) do
      Class.new do
        def self.name
          'Namespace::ResourceClass'
        end # class method name
      end # class
    end # let

    it { expect(described_class).to respond_to(:[]).with(1).argument }

    it 'should create a subclass' do
      subclass = described_class[resource_class]

      expect(subclass).to be_a Class
      expect(subclass).to be < described_class

      expect(subclass.name).
        to be == "#{described_class.name}[#{resource_class.name}]"
    end # it

    it 'should set the resource class' do
      subclass = described_class[resource_class]

      expect(subclass.resource_class).to be resource_class
    end # it
  end # describe

  describe '#collection' do
    let(:collection_name) { 'archived_periodicals' }

    it { expect(instance).to respond_to(:collection).with(0).arguments }

    it 'should return a collection' do
      collection = instance.collection

      expect(collection).to be_a Bronze::Collections::Reference::Collection
      expect(collection.name).to be == collection_name
      expect(collection.repository).to be repository
    end # it
  end # describe

  describe '#repository' do
    include_examples 'should have reader',
      :repository,
      ->() { be == repository }
  end # describe

  describe '#repository=' do
    let(:new_repository) { double('repository') }

    it 'should define the private writer' do
      expect(instance).not_to respond_to(:repository=)

      expect(instance).to respond_to(:repository=, true).with(1).argument
    end # it

    it 'should set the repository' do
      expect { instance.send :repository=, new_repository }.
        to change(instance, :repository).
        to be new_repository
    end # it
  end # describe

  describe '::resource_class' do
    it 'should define the reader' do
      expect(described_class).
        to have_reader(:resource_class).
        with_value(resource_class)
    end # it
  end # describe

  describe '::resource_class=' do
    let(:new_resource_class) { Class.new }

    it 'should define the writer' do
      expect(described_class).not_to respond_to(:resource_class=)

      expect(described_class).
        to respond_to(:resource_class=, true).
        with(1).argument
    end # it

    it 'should set the resource class' do
      expect { described_class.send :resource_class=, new_resource_class }.
        to change(described_class, :resource_class).
        to be new_resource_class
    end # it
  end # describe

  describe '#resource_name' do
    let(:expected) { 'archived_periodicals' }

    include_examples 'should have reader',
      :resource_name,
      ->() { be == expected }
  end # describe
end # describe
