# spec/bronze/operations/resources/resource_operation_spec.rb

require 'bronze/operations/operation'
require 'bronze/operations/resources/resource_operation'

RSpec.describe Bronze::Operations::Resources::ResourceOperation do
  shared_context 'when a resource class is set' do
    let(:resource_class) do
      Class.new do
        def self.name
          'Publications::ArchivedPeriodical'
        end # class method name
      end # class
    end # let

    before(:example) { described_class.send :resource_class=, resource_class }
  end # shared_context

  let(:described_class) do
    Spec::ResourceOperation
  end # let
  let(:instance) { described_class.new }

  mock_class Spec, :ResourceOperation do |klass|
    klass.send :include, Bronze::Operations::Resources::ResourceOperation
  end # mock_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
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

  describe '::resource_class' do
    it 'should define the reader' do
      expect(described_class).
        to have_reader(:resource_class).
        with_value(nil)
    end # it

    wrap_context 'when a resource class is set' do
      it { expect(described_class.resource_class).to be resource_class }
    end # wrap_context
  end # describe

  describe '::resource_class=' do
    let(:resource_class) { Class.new }

    it 'should define the writer' do
      expect(described_class).not_to respond_to(:resource_class=)

      expect(described_class).
        to respond_to(:resource_class=, true).
        with(1).argument
    end # it

    it 'should set the resource class' do
      expect { described_class.send :resource_class=, resource_class }.
        to change(described_class, :resource_class).
        to be resource_class
    end # it
  end # describe

  describe '#resource_class' do
    include_examples 'should have reader', :resource_class, nil

    wrap_context 'when a resource class is set' do
      it { expect(instance.resource_class).to be resource_class }
    end # wrap_context
  end # describe

  describe '#resource_name' do
    include_examples 'should have reader', :resource_name, nil

    wrap_context 'when a resource class is set' do
      let(:expected) { 'archived_periodicals' }

      it { expect(instance.resource_name).to be == expected }
    end # wrap_context
  end # describe
end # describe
