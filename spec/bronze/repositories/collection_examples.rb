# spec/bronze/repositories/collection_examples.rb

module Spec::Repositories
  module CollectionExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should implement the Collection interface' do
      describe '#all' do
        it { expect(instance).to respond_to(:all).with(0).arguments }
      end # describe

      describe '#count' do
        it { expect(instance).to respond_to(:count).with(0).arguments }
      end # describe

      describe '#delete' do
        it { expect(instance).to respond_to(:delete).with(1).argument }
      end # describe

      describe '#insert' do
        it { expect(instance).to respond_to(:insert).with(1).argument }
      end # describe

      describe '#update' do
        it { expect(instance).to respond_to(:update).with(2).arguments }
      end # describe
    end # shared_examples
  end # module
end # module
