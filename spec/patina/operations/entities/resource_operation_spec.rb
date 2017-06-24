# spec/patina/operations/entities/resource_operation_spec.rb

require 'patina/operations/entities/resource_operation'

require 'support/example_entity'

RSpec.describe Patina::Operations::Entities::ResourceOperation do
  let(:described_class) do
    Class.new do
      include Patina::Operations::Entities::ResourceOperation
    end # class
  end # let
  let(:resource_class) { Spec::ArchivedPeriodical }
  let(:instance)       { described_class.new resource_class }

  options = { :base_class => Spec::ExampleEntity }
  example_class 'Spec::ArchivedPeriodical', options do |klass|
    klass.attribute :title,  String
    klass.attribute :volume, Integer
  end # example_class

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
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
end # describe
