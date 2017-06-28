# spec/bronze/entities/operations/entity_operation_examples.rb

module Spec::Entities
  module Operations; end
end # module

module Spec::Entities::Operations::EntityOperationExamples
  extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

  shared_examples 'should implement the EntityOperation methods' do
    describe '::subclass' do
      it { expect(described_class).to respond_to(:subclass).with(1).argument }

      it 'should return a subclass of the operation class' do
        subclass = described_class.subclass(entity_class)

        expect(subclass).to be_a Class
        expect(subclass.superclass).to be described_class
        expect(subclass).to be_constructible.with(arguments.count).arguments
        expect(subclass.new.entity_class).to be entity_class
      end # it
    end # describe

    describe '#entity_class' do
      include_examples 'should have reader',
        :entity_class,
        ->() { entity_class }
    end # describe
  end # shared_examples
end # module
