# spec/bronze/constraints/constraint_examples.rb

module Spec::Constraints
  module ConstraintExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should return false and the errors object' do |proc = nil|
      describe 'should return false and the errors object' do
        let(:match_method) { defined?(super()) ? super() : :match }

        it do
          result, errors = instance.send match_method, object

          expect(result).to be false

          if proc.is_a?(Proc)
            instance_exec(errors, &proc)
          elsif defined?(error_type)
            expect(errors).to include { |error|
              next false unless error.type == error_type

              if defined?(error_params)
                next false unless error.params == error_params
              end # if

              true
            } # end errors
          else
            expect(errors).not_to satisfy(&:empty?)
          end # if
        end # it
      end # describe

      describe 'should update the errors object' do
        let(:match_method)  { defined?(super()) ? super() : :match }
        let(:passed_errors) { Bronze::Errors::Errors.new }

        it do
          _, errors = instance.send match_method, object, passed_errors

          expect(passed_errors).to be == errors
        end # it
      end # describe
    end # shared_examples

    shared_examples 'should return true and an empty errors object' do
      describe 'should return false and the errors object' do
        let(:match_method) { defined?(super()) ? super() : :match }

        it do
          result, errors = instance.send match_method, object

          expect(result).to be true
          expect(errors).to satisfy(&:empty?)
        end # it
      end # describe

      describe 'should not update the errors object' do
        let(:match_method)  { defined?(super()) ? super() : :match }
        let(:passed_errors) { Bronze::Errors::Errors.new }

        it do
          _, errors = instance.send match_method, object, passed_errors

          expect(passed_errors).to be == errors
        end # it
      end # describe
    end # shared_examples
  end # module
end # module
