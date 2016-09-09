# spec/bronze/operations/repository_operation_spec.rb

require 'bronze/operations/operation'
require 'bronze/operations/repository_operation'

RSpec.describe Bronze::Operations::RepositoryOperation do
  let(:described_class) do
    operation_class = Class.new(Bronze::Operations::Operation)
    operation_class.send :include, super()
    operation_class
  end # let
  let(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '#repository' do
    include_examples 'should have reader', :repository, nil
  end # describe

  describe '#repository=' do
    let(:repository) { double('repository') }

    it 'should define the private reader' do
      expect(instance).not_to respond_to(:repository=)

      expect(instance).to respond_to(:repository=, true).with(1).argument
    end # it

    it 'should set the repository' do
      expect { instance.send :repository=, repository }.
        to change(instance, :repository).
        to be repository
    end # it
  end # describe
end # describe
