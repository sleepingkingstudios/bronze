# spec/patina/operations/entities/error_messages_spec.rb

require 'patina/operations/entities/error_messages'

RSpec.describe Patina::Operations::Entities::ErrorMessages do
  describe '::RECORD_NOT_FOUND' do
    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:RECORD_NOT_FOUND).
        with_value('operations.entities.record_not_found')
    end # it
  end # describe
end # describe
