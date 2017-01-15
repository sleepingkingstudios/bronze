# spec/bronze/entities/associations/associations_examples.rb

require 'sleeping_king_studios/tools/toolbelt'

require 'bronze/entities/attributes/attributes_examples'
require 'support/example_entity'

module Spec::Entities
  module Associations; end
end # module

module Spec::Entities::Associations::AssociationsExamples
  extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

  include Spec::Entities::Attributes::AttributesExamples

  shared_context 'when associations are defined for the class' do
    mock_class Spec, :Author, :base_class => Bronze::Entities::Entity

    let(:described_class) do
      Class.new(super()) do
        references_one :author, :class_name => 'Spec::Author'
      end # class
    end # let
  end # shared_context

  shared_context 'with an associated entity' do
    let(:prior_value) do
      defined?(super()) ? super() : association_class.new
    end # let

    before(:example) do
      entity.send(:"#{association_name}=", prior_value)
    end # before example
  end # shared_context

  shared_examples 'should update the association state' do
    def safe_set_value value
      set_value value
    rescue ArgumentError
      nil
    end # method safe_set_value

    shared_example 'should raise a validation error' do
      expect { set_value new_value }.
        to raise_error ArgumentError,
          "#{assoc_name} must be a #{association_class.name}"
    end # shared_example

    shared_example 'should return the new value' do
      expect(set_value new_value).to be new_value
    end # shared_example

    ############################################################################
    ###                          Association Values                          ###
    ############################################################################

    shared_example 'should not change the association value' do
      expect { safe_set_value new_value }.
        not_to change(entity, reader_name)
    end # shared_example

    shared_example 'should clear the association value' do
      expect { set_value new_value }.
        to change(entity, reader_name).
        to be_nil
    end # shared_example

    shared_example 'should change the association value' do
      expect { set_value new_value }.
        to change(entity, reader_name).
        to be == new_value
    end # shared_example

    shared_example 'should not change the foreign key' do
      expect { safe_set_value new_value }.
        not_to change(entity, foreign_key)
    end # shared_example

    shared_example 'should clear the foreign key' do
      expect { set_value new_value }.
        to change(entity, foreign_key).
        to be_nil
    end # shared_example

    shared_example 'should change the foreign key' do
      expect { safe_set_value new_value }.
        to change(entity, foreign_key).
        to be == new_value.id
    end # shared_example

    ############################################################################
    ###                          New Value Inverses                          ###
    ############################################################################

    shared_example 'should change the new value inverse foreign key' do
      expect { set_value new_value }.
        to change(new_value, inverse_foreign_key).
        to be == entity.id
    end # shared_example

    shared_example 'should change the new value inverse value' do
      expect { set_value new_value }.
        to change(new_value, inverse_name).
        to be == entity
    end # shared_example

    shared_example 'should clear the prior inverse association value' do
      expect { set_value new_value }.
        to change(prior_inverse, reader_name).
        to be nil
    end # shared_example

    shared_example 'should clear the prior inverse foreign key' do
      expect { set_value new_value }.
        to change(prior_inverse, foreign_key).
        to be nil
    end # shared_example

    ############################################################################
    ###                         Prior Value Inverses                         ###
    ############################################################################

    shared_example 'should not change the prior value inverse foreign key' do
      expect { safe_set_value new_value }.
        not_to change(prior_value, inverse_foreign_key)
    end # shared_example

    shared_example 'should clear the prior value inverse foreign key' do
      expect { set_value new_value }.
        to change(prior_value, inverse_foreign_key).
        to be nil
    end # shared_example

    shared_example 'should not change the prior value inverse value' do
      expect { safe_set_value Object.new }.
        not_to change(prior_value, inverse_name)
    end # shared_example

    shared_example 'should clear the prior value inverse value' do
      expect { set_value new_value }.
        to change(prior_value, inverse_name).
        to be nil
    end # shared_example
  end # shared_examples

  desc = 'should define has_one association'
  shared_examples desc do |assoc_name, assoc_opts = {}|
    reader_name = assoc_name
    writer_name = :"#{assoc_name}="

    describe "should define association has_one :#{assoc_name}" do
      let(:entity)      { defined?(super()) ? super() : instance }
      let(:assoc_name)  { assoc_name }
      let(:reader_name) { reader_name }
      let(:writer_name) { writer_name }

      describe "##{reader_name}" do
        it 'should define the reader' do
          expect(entity).to have_reader(reader_name).with_value(nil)
        end # it

        wrap_context 'with an associated entity' do
          it { expect(entity.send reader_name).to be prior_value }
        end # wrap_context
      end # describe

      describe "##{reader_name}?" do
        it 'should define the predicate' do
          expect(entity).to have_predicate(reader_name).with_value(false)
        end # it

        wrap_context 'with an associated entity' do
          it { expect(entity.send :"#{reader_name}?").to be true }
        end # wrap_context
      end # describe

      describe "##{writer_name}" do
        shared_context 'when the association already has an inverse object' do
          let(:prior_inverse) { entity_class.new }

          before(:example) do
            prior_inverse.send(writer_name, new_value)
          end # before
        end # shared_context

        include_examples 'should update the association state'

        let(:inverse_name) do
          assoc_opts.fetch :inverse do
            tools = SleepingKingStudios::Tools::Toolbelt.instance
            str   = entity_class.name.split('::').last
            str   = tools.string.singularize(str)
            str   = tools.string.underscore(str)

            str.intern
          end # fetch
        end # let
        let(:inverse_foreign_key) { :"#{inverse_name}_id" }

        define_method :set_value do |value|
          entity.send writer_name, value
        end # method

        it 'should define the writer' do
          expect(entity).to have_reader(writer_name)
        end # it

        describe 'with nil' do
          let(:new_value) { nil }

          include_examples 'should return the new value'

          include_examples 'should not change the association value'
        end # describe

        describe 'with an object' do
          let(:new_value) { Object.new }

          include_examples 'should raise a validation error'

          include_examples 'should not change the association value'
        end # describe

        describe 'with an entity' do
          let(:other_class) { Class.new(Bronze::Entities::Entity) }
          let(:new_value)   { other_class.new }

          include_examples 'should raise a validation error'

          include_examples 'should not change the association value'
        end # describe

        describe 'with an instance of the association class' do
          let(:new_value) { association_class.new }

          include_examples 'should return the new value'

          include_examples 'should change the association value'

          include_examples 'should change the new value inverse foreign key'

          include_examples 'should change the new value inverse value'

          wrap_context 'when the association already has an inverse object' do
            include_examples 'should change the association value'

            include_examples 'should change the new value inverse foreign key'

            include_examples 'should change the new value inverse value'

            include_examples 'should clear the prior inverse association value'
          end # wrap_context
        end # describe

        wrap_context 'with an associated entity' do
          describe 'with nil' do
            let(:new_value) { nil }

            include_examples 'should return the new value'

            include_examples 'should clear the association value'

            include_examples 'should clear the prior value inverse foreign key'

            include_examples 'should clear the prior value inverse value'
          end # describe

          describe 'with an object' do
            let(:new_value) { Object.new }

            include_examples 'should raise a validation error'

            include_examples 'should not change the association value'

            include_examples \
              'should not change the prior value inverse foreign key'

            include_examples 'should not change the prior value inverse value'
          end # describe

          describe 'with an entity' do
            let(:other_class) { Class.new(Bronze::Entities::Entity) }
            let(:new_value) { other_class.new }

            include_examples 'should raise a validation error'

            include_examples 'should not change the association value'

            include_examples \
              'should not change the prior value inverse foreign key'

            include_examples 'should not change the prior value inverse value'
          end # describe

          describe 'with an instance of the association class' do
            let(:new_value) { association_class.new }

            include_examples 'should return the new value'

            include_examples 'should change the association value'

            include_examples 'should change the new value inverse foreign key'

            include_examples 'should change the new value inverse value'

            include_examples 'should clear the prior value inverse foreign key'

            include_examples 'should clear the prior value inverse value'

            wrap_context 'when the association already has an inverse object' do
              include_examples 'should change the association value'

              include_examples 'should change the new value inverse foreign key'

              include_examples 'should change the new value inverse value'

              include_examples \
                'should clear the prior value inverse foreign key'

              include_examples 'should clear the prior value inverse value'

              include_examples 'should clear the prior value inverse value'
            end # wrap_context
          end # describe
        end # wrap_context
      end # describe
    end # describe
  end # shared_examples

  desc = 'should define references_one association'
  shared_examples desc do |assoc_name, assoc_opts = {}|
    reader_name = assoc_name
    writer_name = :"#{assoc_name}="
    foreign_key = assoc_opts.fetch :foreign_key, :"#{assoc_name}_id"

    tools        = SleepingKingStudios::Tools::Toolbelt.instance
    inverse_name = assoc_opts[:inverse]

    describe "should define association references_one :#{assoc_name}" do
      let(:entity)      { defined?(super()) ? super() : instance }
      let(:assoc_name)  { assoc_name }
      let(:foreign_key) { foreign_key }
      let(:reader_name) { reader_name }
      let(:writer_name) { writer_name }

      include_examples 'should define attribute', foreign_key, String

      describe "##{foreign_key}" do
        wrap_context 'with an associated entity' do
          it { expect(entity.send foreign_key).to be == prior_value.id }
        end # wrap_context
      end # describe

      describe "##{reader_name}" do
        it 'should define the reader' do
          expect(entity).to have_reader(reader_name).with_value(nil)
        end # it

        wrap_context 'with an associated entity' do
          it { expect(entity.send reader_name).to be prior_value }
        end # wrap_context
      end # describe

      describe "##{reader_name}?" do
        it 'should define the predicate' do
          expect(entity).to have_predicate(reader_name).with_value(false)
        end # it

        wrap_context 'with an associated entity' do
          it { expect(entity.send :"#{reader_name}?").to be true }
        end # wrap_context
      end # describe

      describe "##{writer_name}" do
        shared_context 'when the association already has an inverse object' do
          let(:prior_inverse) { entity_class.new }

          before(:example) do
            prior_inverse.send(writer_name, new_value)
          end # before
        end # shared_context

        let(:inverse_name) { inverse_name }

        include_examples 'should update the association state'

        define_method :set_value do |value|
          entity.send writer_name, value
        end # method set_value

        it 'should define the writer' do
          expect(entity).to have_reader(writer_name)
        end # it

        describe 'with nil' do
          let(:new_value) { nil }

          include_examples 'should return the new value'

          include_examples 'should not change the association value'
        end # describe

        describe 'with an object' do
          let(:new_value) { Object.new }

          include_examples 'should raise a validation error'

          include_examples 'should not change the association value'

          include_examples 'should not change the foreign key'
        end # describe

        describe 'with an entity' do
          let(:other_class) { Class.new(Bronze::Entities::Entity) }
          let(:new_value) { other_class.new }

          include_examples 'should raise a validation error'

          include_examples 'should not change the association value'

          include_examples 'should not change the foreign key'
        end # describe

        describe 'with an instance of the association class' do
          let(:new_value) { association_class.new }

          include_examples 'should return the new value'

          include_examples 'should change the association value'

          include_examples 'should change the foreign key'
        end # describe

        wrap_context 'with an associated entity' do
          describe 'with nil' do
            let(:new_value) { nil }

            include_examples 'should return the new value'

            include_examples 'should clear the association value'

            include_examples 'should clear the foreign key'
          end # describe

          describe 'with an object' do
            let(:new_value) { Object.new }

            include_examples 'should raise a validation error'

            include_examples 'should not change the association value'

            include_examples 'should not change the foreign key'
          end # describe

          describe 'with an entity' do
            let(:other_class) { Class.new(Bronze::Entities::Entity) }
            let(:new_value)   { other_class.new }

            include_examples 'should raise a validation error'

            include_examples 'should not change the association value'

            include_examples 'should not change the foreign key'
          end # describe

          describe 'with an instance of the association class' do
            let(:new_value) { association_class.new }

            include_examples 'should return the new value'

            include_examples 'should change the association value'

            include_examples 'should change the foreign key'
          end # describe
        end # wrap_context

        if inverse_name && tools.string.singular?(inverse_name.to_s)
          describe 'with an instance of the association class' do
            let(:new_value) { association_class.new }

            wrap_context 'when the association already has an inverse object' do
              include_examples 'should change the new value inverse value'

              include_examples \
                'should clear the prior inverse association value'

              include_examples 'should clear the prior inverse foreign key'
            end # wrap_context
          end # describe

          wrap_context 'with an associated entity' do
            describe 'with nil' do
              let(:new_value) { nil }

              include_examples 'should clear the prior value inverse value'
            end # describe

            describe 'with an instance of the association class' do
              let(:new_value) { association_class.new }

              include_examples 'should clear the prior value inverse value'

              include_examples 'should change the new value inverse value'

              desc = 'when the association already has an inverse object'
              wrap_context desc do
                include_examples 'should clear the prior value inverse value'

                include_examples 'should change the new value inverse value'

                include_examples \
                  'should clear the prior inverse association value'

                include_examples 'should clear the prior inverse foreign key'
              end # wrap_context
            end # describe
          end # wrap_context
        end # if
      end # describe
    end # describe
  end # shared_examples

  shared_examples 'should implement the Associations methods' do
    describe '::associations' do
      it 'should define the reader' do
        expect(described_class).
          to have_reader(:associations).
          with_value(an_instance_of Hash)
      end # it

      it 'should return a frozen copy of the associations hash' do
        metadata =
          Bronze::Entities::Associations::Metadata::AssociationMetadata.new(
            entity_class,
            :references_one,
            :virus,
            :class_name => 'Virus'
          ) # end metadata

        expect { described_class.associations[:infection] = metadata }.
          to raise_error(RuntimeError)

        expect(described_class.associations.keys).
          to contain_exactly(*defined_associations.keys)
      end # it

      wrap_context 'when associations are defined for the class' do
        let(:expected) do
          [*defined_associations.keys, :author]
        end # let

        it 'should return the associations metadata' do
          expect(described_class.associations.keys).
            to contain_exactly(*expected)
        end # it

        context 'when an entity subclass is defined' do
          mock_class Spec, :Publisher, :base_class => Bronze::Entities::Entity

          let(:subclass) do
            Class.new(described_class) do
              references_one :publisher, :class_name => 'Spec::Publisher'
            end # let
          end # let

          it 'should return the class and superclass attributes' do
            expect(described_class.associations.keys).
              to contain_exactly(*expected)

            expect(subclass.associations.keys).
              to contain_exactly(*expected, :publisher)
          end # it
        end # context
      end # wrap_context
    end # describe

    describe '::foreign_key' do
      shared_context 'when the attribute has been defined' do
        let!(:metadata) do
          described_class.foreign_key(attribute_name)
        end # let!
      end # shared_context

      it 'should respond to the method' do
        expect(described_class).to respond_to(:foreign_key).with(1).arguments
      end # it

      describe 'with a valid attribute name' do
        let(:attribute_name) { :association_id }
        let(:attribute_type) { described_class::KEY_TYPE }
        let(:attributes) do
          super().merge :association_id => Bronze::Entities::Ulid.generate
        end # let
        let(:attribute_type_class) do
          Bronze::Entities::Attributes::AttributeType
        end # let

        it 'should set and return the metadata' do
          metadata = described_class.foreign_key attribute_name
          mt_class = Bronze::Entities::Attributes::AttributeMetadata

          expect(metadata).to be_a mt_class
          expect(metadata.attribute_name).to be == attribute_name
          expect(metadata.attribute_type).to be_a attribute_type_class
          expect(metadata.object_type).to be == attribute_type
          expect(metadata.foreign_key?).to be true

          expect(described_class.attributes[attribute_name]).to be metadata
        end # it

        wrap_context 'when the attribute has been defined' do
          let(:expected_value) { attributes.fetch attribute_name }
          let(:updated_value)  { Bronze::Entities::Ulid.generate }

          include_examples 'should define attribute', :association_id
        end # wrap_context
      end # describe
    end # describe

    describe '::has_one' do
      shared_context 'when the association has been defined' do
        let!(:metadata) do
          described_class.has_one(
            association_name,
            association_opts
          ) # end has_one
        end # let!
      end # shared_context

      it 'should respond to the method' do
        expect(described_class).
          to respond_to(:has_one).
          with(1..2).arguments
      end # it

      describe 'with a valid association name' do
        let(:association_class) { Spec::Cover }
        let(:association_name)  { :cover }
        let(:association_opts) do
          { :class_name => 'Spec::Cover', :inverse => :book }
        end # let

        options = { :base_class => Spec::ExampleEntity }
        mock_class Spec, :Cover, options do |klass|
          klass.references_one(
            :book,
            :class_name => 'Spec::Book',
            :inverse    => :cover
          ) # end references_one
        end # mock_class

        it 'should set and return the metadata' do
          metadata = described_class.has_one(
            association_name,
            association_opts
          ) # end references_one
          mt_class = Bronze::Entities::Associations::Metadata::HasOneMetadata

          expect(metadata).to be_a mt_class
          expect(metadata.association_name).to be == association_name
          expect(metadata.association_type).to be == mt_class::ASSOCIATION_TYPE
          expect(metadata.association_class).to be Spec::Cover
          expect(metadata.inverse_name).to be == :book

          expect(described_class.associations[association_name]).to be metadata
        end # it

        wrap_context 'when the association has been defined' do
          include_examples 'should define has_one association', :cover

          context 'when the reader method is overwritten' do
            let(:cover)      { Spec::Cover.new }
            let(:attributes) { super().merge :cover => cover }

            before(:example) do
              described_class.send :define_method,
                association_name,
                lambda {
                  value = super()

                  value.inspect
                } # end lambda
            end # before example

            it 'should inherit from the base definition' do
              expect(instance.send association_name).to be == cover.inspect
            end # it
          end # context

          context 'when the writer method is overwritten' do
            let(:cover) { Spec::Cover.new }

            before(:example) do
              described_class.send :define_method,
                "#{association_name}=",
                ->(value) { super(value.dup.freeze) }
            end # before example

            it 'should inherit from the base definition' do
              be_a_frozen_copy =
                satisfy { |obj| obj == cover }.
                and satisfy { |obj| obj.object_id != cover.object_id }.
                and satisfy(&:frozen?)

              expect { instance.send "#{association_name}=", cover }.
                to change(instance, association_name).
                to be_a_frozen_copy
            end # it
          end # context
        end # wrap_context
      end # describe
    end # describe

    describe '::references_one' do
      shared_context 'when the association has been defined' do
        let!(:metadata) do
          described_class.references_one(
            association_name,
            association_opts
          ) # end references_one
        end # let!
      end # shared_context

      it 'should respond to the method' do
        expect(described_class).
          to respond_to(:references_one).
          with(1..2).arguments
      end # it

      it 'should alias the method' do
        expect(described_class).to alias_method(:references_one).as(:belongs_to)
      end # it

      describe 'with a valid association name' do
        let(:association_name)  { :author }
        let(:association_opts)  { { :class_name => 'Spec::Author' } }
        let(:association_class) { Spec::Author }

        mock_class Spec, :Author, :base_class => Bronze::Entities::Entity

        it 'should set and return the metadata' do
          metadata = described_class.references_one(
            association_name,
            association_opts
          ) # end references_one
          mt_class =
            Bronze::Entities::Associations::Metadata::ReferencesOneMetadata

          expect(metadata).to be_a mt_class
          expect(metadata.association_name).to be == association_name
          expect(metadata.association_type).to be == mt_class::ASSOCIATION_TYPE
          expect(metadata.association_class).to be Spec::Author

          expect(described_class.associations[association_name]).to be metadata
        end # it

        wrap_context 'when the association has been defined' do
          include_examples 'should define references_one association', :author

          context 'when the reader method is overwritten' do
            let(:author)     { Spec::Author.new }
            let(:attributes) { super().merge :author => author }

            before(:example) do
              described_class.send :define_method,
                association_name,
                lambda {
                  value = super()

                  value.inspect
                } # end lambda
            end # before example

            it 'should inherit from the base definition' do
              expect(instance.send association_name).to be == author.inspect
            end # it
          end # context

          context 'when the writer method is overwritten' do
            let(:author) { Spec::Author.new }

            before(:example) do
              described_class.send :define_method,
                "#{association_name}=",
                ->(value) { super(value.dup.freeze) }
            end # before example

            it 'should inherit from the base definition' do
              be_a_frozen_copy =
                satisfy { |obj| obj == author }.
                and satisfy { |obj| obj.object_id != author.object_id }.
                and satisfy(&:frozen?)

              expect { instance.send "#{association_name}=", author }.
                to change(instance, association_name).
                to be_a_frozen_copy
            end # it
          end # context

          describe 'with :inverse => one association' do
            let(:association_opts) { super().merge :inverse => :book }

            before(:example) do
              Spec::Author.has_one :book, :class_name => 'Spec::Book'
            end # before example

            include_examples 'should define references_one association',
              :author,
              :inverse => :book
          end # describe
        end # wrap_context
      end # describe
    end # describe
  end # shared_examples
end # module
