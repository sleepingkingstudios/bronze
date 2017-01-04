# spec/bronze/entities/associations/metadata/association_metadata_examples.rb

module Spec::Entities
  module Associations; end
end # module

module Spec::Entities::Associations
  module MetadataExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

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

      describe '#foreign_key' do
        include_examples 'should have reader', :foreign_key
      end # describe

      describe '#foreign_key?' do
        include_examples 'should have predicate', :foreign_key?
      end # describe

      describe '#foreign_key_reader_name' do
        include_examples 'should have reader', :foreign_key_reader_name
      end # describe

      describe '#foreign_key_writer_name' do
        include_examples 'should have reader', :foreign_key_writer_name
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
