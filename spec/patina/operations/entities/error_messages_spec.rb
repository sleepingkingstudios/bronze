# spec/patina/operations/entities/error_messages_spec.rb

require 'patina/operations/entities/error_messages'

RSpec.describe Patina::Operations::Entities::ErrorMessages do
  describe '::INVALID_RESOURCE' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:INVALID_RESOURCE).
        with_value('errors.operations.entities.invalid_resource')
    end # it
  end # describe

  describe '::RECORD_ALREADY_EXISTS' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:RECORD_ALREADY_EXISTS).
        with_value('errors.operations.entities.record_already_exists')
    end # it
  end # describe

  describe '::RECORD_NOT_FOUND' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:RECORD_NOT_FOUND).
        with_value('errors.operations.entities.record_not_found')
    end # it
  end # describe
end # describe
