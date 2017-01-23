# spec/bronze/entities/associations/metadata/association_metadata_examples.rb

module Spec::Entities
  module Associations; end
end # module

module Spec::Entities::Associations
  module MetadataExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when options[:inverse] is nil' do
      let(:association_options) do
        super().merge :inverse => nil
      end # let
    end # shared_context

    shared_context 'when options[:inverse] is unset' do
      let(:association_options) do
        super().tap { |hsh| hsh.delete :inverse }
      end # let
    end # shared_context

    shared_context 'when the inverse relation is undefined' do
      before(:example) do
        allow(association_class).to receive(:associations).and_return({})
      end # before example
    end # shared_context

    shared_examples 'should validate the inverse metadata inverse' do
      context 'when the inverse metadata has other metadata as its inverse' do
        let(:error_class) do
          Bronze::Entities::Associations::InverseAssociationError
        end # let
        let(:other_name) { :invalid_association }
        let(:other_metadata) do
          described_class.new(entity_class, other_name, association_options)
        end # let
        let(:expected_message) do
          "#{instance.send(:expected_inverse_message)}, but " \
          ":#{inverse_metadata.name} already has inverse association " \
          "#{other_metadata.type} :#{other_metadata.name}"
        end # let

        before(:example) do
          allow(inverse_metadata).
            to receive(:get_inverse_metadata).
            and_return(other_metadata)
        end # before example

        it 'should not raise an error' do
          expect { call_method }.
            to raise_error error_class, expected_message
        end # it
      end # context

      context 'when the inverse metadata has the metadata as its inverse' do
        before(:example) do
          allow(inverse_metadata).
            to receive(:get_inverse_metadata).
            and_return(instance)
        end # before example

        it 'should not raise an error' do
          expect { call_method }.not_to raise_error
        end # it
      end # context
    end # shared_examples

    shared_examples 'should validate the inverse metadata presence' do
      let(:error_class) do
        Bronze::Entities::Associations::InverseAssociationError
      end # let
      let(:expected_message) do
        "#{instance.send(:expected_inverse_message)}, but does not define " \
        'the inverse association'
      end # let

      it 'should raise an error' do
        expect { call_method }.
          to raise_error error_class, expected_message
      end # it
    end # shared_examples

    shared_examples 'should validate the inverse metadata type' do
      context 'when the inverse metadata type is invalid' do
        let(:inverse_metadata) do
          build_invalid_inverse_metadata(inverse_name)
        end # let
        let(:error_class) do
          Bronze::Entities::Associations::InverseAssociationError
        end # let
        let(:expected_message) do
          "#{instance.send(:expected_inverse_message)}, but :#{inverse_name} " \
          "is a #{inverse_metadata.type} association"
        end # let

        it 'should raise an error' do
          expect { call_method }.
            to raise_error error_class, expected_message
        end # it
      end # context
    end # shared_examples

    shared_examples 'should implement the AssociationMetadata methods' do
      describe '::optional_keys' do
        it 'should define the reader' do
          expect(described_class).
            to have_reader(:optional_keys).
            with_value(an_instance_of Array)
        end # it
      end # describe

      describe '::required_keys' do
        it 'should define the reader' do
          expect(described_class).
            to have_reader(:required_keys).
            with_value(an_instance_of Array)
        end # it
      end # describe

      describe '::valid_keys' do
        let(:expected) do
          described_class.optional_keys + described_class.required_keys
        end # let

        it 'should define the reader' do
          expect(described_class).
            to have_reader(:valid_keys).
            with_value(be == expected)
        end # it
      end # describe

      describe '#association_class' do
        include_examples 'should have reader',
          :association_class,
          ->() { association_class }

        it { expect(instance).to alias_method(:association_class).as(:klass) }

        context 'with an invalid class name' do
          let(:class_name) { 'InvalidClass' }

          before(:example) do
            allow(instance).to receive(:class_name).and_return(class_name)
          end # before example

          it 'should raise an error' do
            expect { instance.association_class }.
              to raise_error NameError,
                "uninitialized constant #{described_class}::#{class_name}"
          end # it
        end # context
      end # describe

      describe '#association_name' do
        include_examples 'should have reader',
          :association_name,
          ->() { be == association_name }

        it { expect(instance).to alias_method(:association_name).as(:name) }
      end # describe

      describe '#association_options' do
        let(:options) do
          hash_tools = SleepingKingStudios::Tools::HashTools

          hash_tools.convert_keys_to_symbols(association_options)
        end # let

        include_examples 'should have reader',
          :association_options,
          ->() { be == options }

        it 'should alias the method' do
          expect(instance).to alias_method(:association_options).as(:options)
        end # it
      end # describe

      describe '#association_type' do
        include_examples 'should have reader', :association_type

        it { expect(instance).to alias_method(:association_type).as(:type) }
      end # describe

      describe '#entity_class' do
        include_examples 'should have reader',
          :entity_class,
          ->() { entity_class }
      end # describe

      describe '#foreign_key' do
        include_examples 'should have reader', :foreign_key
      end # describe

      describe '#foreign_key?' do
        include_examples 'should have predicate', :foreign_key?
      end # describe

      describe '#foreign_key_metadata' do
        include_examples 'should have reader', :foreign_key_metadata
      end # describe

      describe '#foreign_key_reader_name' do
        include_examples 'should have reader', :foreign_key_reader_name
      end # describe

      describe '#foreign_key_type' do
        include_examples 'should have reader', :foreign_key_type
      end # describe

      describe '#foreign_key_writer_name' do
        include_examples 'should have reader', :foreign_key_writer_name
      end # describe

      describe '#inverse?' do
        include_examples 'should have predicate', :inverse?
      end # describe

      describe '#inverse_metadata' do
        include_examples 'should have reader', :inverse_metadata
      end # describe

      describe '#inverse_name' do
        include_examples 'should have reader', :inverse_name
      end # describe

      describe '#many?' do
        include_examples 'should have predicate', :many?
      end # describe

      describe '#one?' do
        include_examples 'should have predicate', :one?
      end # describe

      describe '#reader_name' do
        include_examples 'should have reader',
          :reader_name,
          ->() { be == association_name }
      end # describe

      describe '#writer_name' do
        include_examples 'should have reader',
          :writer_name,
          ->() { be == :"#{association_name}=" }
      end # describe
    end # shared_examples
  end # module
end # module
