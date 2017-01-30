# spec/bronze/entities/persistence_examples.rb

module Spec::Entities
  module PersistenceExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should implement the Persistence methods' do
      describe '#persist' do
        it { expect(instance).to respond_to(:persist).with(0).arguments }

        it 'should mark the entity as persisted' do
          expect { instance.persist }.
            to change(instance, :persisted?).
            to be true
        end # it
      end # desrribe

      describe '#persisted?' do
        it { expect(instance).to have_predicate(:persisted?).with_value(false) }
      end # describe
    end # shared_examples
  end # module
end # module
