# spec/bronze/constraints/constraints_examples.rb

module Spec::Constraints
  module ConstraintsExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should return false and the errors object' do
      it 'should return false and the errors object' do
        result, errors = instance.match object

        expect(result).to be false

        if defined?(error_type)
          expect(errors).to include { |error|
            return false unless error.type == error_type

            if defined?(error_params)
              return false unless error.params == error_params
            end # if

            true
          } # end errors
        else
          expect(errors).not_to satisfy(&:empty?)
        end # if
      end # it
    end # shared_examples

    shared_examples 'should return true and an empty errors object' do
      it 'should return true and an empty errors object' do
        result, errors = instance.match object

        expect(result).to be true
        expect(errors).to satisfy(&:empty?)
      end # it
    end # shared_examples
  end # module
end # module
