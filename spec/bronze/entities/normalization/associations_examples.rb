# spec/bronze/entities/normalization/associations_examples.rb

require 'bronze/entities/entity'

module Spec::Entities
  module Normalization; end
end # module

module Spec::Entities::Normalization
  module AssociationsExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should implement the Normalization::Associations methods' \
    do
      describe '#normalize' do
        shared_context \
          'when the entity class has a references_one association' \
        do
          let(:container) do
            Spec::Container.new(shape: 'treasure chest')
          end
          let(:container_properties) do
            {
              id:    container.id,
              shape: container.shape
            }
          end

          example_class 'Spec::Container', Bronze::Entities::Entity do |klass|
            klass.attribute :shape, String
          end

          before(:example) do
            described_class.references_one :container,
              class_name: 'Spec::Container'
          end
        end

        shared_context 'when the entity class has a has_one association' do
          let(:alloyed_material) do
            Spec::Material.new(
              metal: 'bronze',
              elements: [
                Spec::Element.new(metal: 'copper'),
                Spec::Element.new(metal: 'tin')
              ]
            )
          end
          let(:alloyed_properties) do
            {
              id:      alloyed_material.id,
              book_id: instance.id,
              metal:   alloyed_material.metal
            }
          end
          let(:element_properties) do
            alloyed_material.elements.map(&:attributes)
          end
          let(:pure_material) do
            Spec::Material.new(metal: 'iron')
          end
          let(:pure_properties) do
            {
              id:      pure_material.id,
              book_id: instance.id,
              metal:   pure_material.metal
            }
          end

          example_class 'Spec::Element', Bronze::Entities::Entity \
          do |klass|
            klass.attribute :metal, String

            klass.references_one :material,
              class_name: 'Spec::Material',
              inverse:    :elements
          end

          example_class 'Spec::Material', Bronze::Entities::Entity \
          do |klass|
            klass.attribute :metal, String

            klass.references_one :book,
              class_name: 'Spec::Book',
              inverse:    :material

            klass.has_many :elements,
              class_name: 'Spec::Element',
              inverse:    :material
          end

          before(:example) do
            described_class.has_one :material,
              class_name: 'Spec::Material',
              inverse:    :book
          end
        end

        shared_context 'when the entity class has a has_many association' do
          let(:variants) do
            [
              Spec::Variant.new(color: 'red'),
              Spec::Variant.new(color: 'blue'),
              Spec::Variant.new(color: 'green')
            ]
          end
          let(:variant_properties) do
            instance.variants.map(&:attributes)
          end

          example_class 'Spec::Variant', Bronze::Entities::Entity do |klass|
            klass.attribute :color, String

            klass.references_one :book,
              class_name: 'Spec::Book',
              inverse:    :variants
          end

          before(:example) do
            described_class.has_many :variants,
              class_name: 'Spec::Variant',
              inverse:    :book
          end
        end

        let(:expected) { instance.attributes }

        it 'should define the method' do
          expect(instance).
            to respond_to(:normalize).
            with(0).arguments.
            and_keywords(:associations, :permit)
        end # it

        it { expect(instance.normalize).to be == expected }

        wrap_context 'when the entity class has a references_one association' do
          let(:expected) { super().merge(container_id: nil) }

          it { expect(instance.normalize).to be == expected }

          describe 'with associations: { container: true }' do
            let(:expected) { super().merge(container: nil) }

            it 'should normalize the association' do
              expect(instance.normalize(associations: { container: true }))
                .to be == expected
            end
          end

          context 'when the entity has a container' do
            let(:expected) { super().merge(container_id: container.id) }

            before(:example) { instance.container = container }

            it { expect(instance.normalize).to be == expected }

            describe 'with associations: { container: true }' do
              let(:expected) { super().merge(container: container_properties) }

              it 'should normalize the association' do
                expect(instance.normalize(associations: { container: true }))
                  .to be == expected
              end
            end
          end
        end

        wrap_context 'when the entity class has a has_one association' do
          it { expect(instance.normalize).to be == expected }

          describe 'with associations: { material: true }' do
            let(:expected) { super().merge(material: nil) }

            it 'should normalize the association' do
              expect(instance.normalize(associations: { material: true }))
                .to be == expected
            end
          end

          context 'when the entity has a pure material' do
            before(:example) { instance.material = pure_material }

            it { expect(instance.normalize).to be == expected }

            describe 'with associations: { material: true }' do
              let(:expected) { super().merge(material: pure_properties) }

              it 'should normalize the association' do
                expect(instance.normalize(associations: { material: true }))
                  .to be == expected
              end
            end
          end

          context 'when the entity has an alloyed material' do
            before(:example) { instance.material = alloyed_material }

            it { expect(instance.normalize).to be == expected }

            describe 'with associations: { material: true }' do
              let(:expected) { super().merge(material: alloyed_properties) }

              it 'should normalize the association' do
                expect(instance.normalize(associations: { material: true }))
                  .to be == expected
              end
            end

            describe 'with associations: { material: { elements } }' do
              let(:expected) do
                super().merge(
                  material:
                    alloyed_properties.merge(elements: element_properties)
                )
              end

              it 'should normalize the association' do
                keywords = {
                  associations: {
                    material: {
                      associations: { elements: true }
                    }
                  }
                }

                expect(instance.normalize(keywords)).to be == expected
              end
            end
          end
        end

        wrap_context 'when the entity class has a has_many association' do
          it { expect(instance.normalize).to be == expected }

          describe 'with associations: { variants: true }' do
            let(:expected) { super().merge(variants: []) }

            it 'should normalize the association' do
              expect(instance.normalize(associations: { variants: true }))
                .to be == expected
            end
          end

          context 'when the entity has many variants' do
            before(:example) { instance.variants = variants }

            it { expect(instance.normalize).to be == expected }

            describe 'with associations: { variants: true }' do
              let(:expected) { super().merge(variants: variant_properties) }

              it 'should normalize the association' do
                expect(instance.normalize(associations: { variants: true }))
                  .to be == expected
              end
            end
          end
        end

        context 'when the entity class has many associations' do
          include_context \
            'when the entity class has a references_one association'
          include_context 'when the entity class has a has_one association'
          include_context 'when the entity class has a has_many association'

          let(:title)  { 'The Aeneid' }
          let(:author) { 'Virgil' }
          let(:expected) do
            super().merge(container_id: nil)
          end

          before(:example) do
            described_class.attribute :title,  String
            described_class.attribute :author, String

            instance.title  = title
            instance.author = author
          end

          it { expect(instance.normalize).to be == expected }

          describe 'with associations: { container, material, variants }' do
            let(:expected) do
              super().merge(
                container: nil,
                material:  nil,
                variants:  []
              )
            end

            it 'should normalize the association' do
              keywords = {
                associations: {
                  container: true,
                  material: {
                    associations: { elements: true }
                  },
                  variants: true
                }
              }

              expect(instance.normalize(keywords)).to be == expected
            end
          end

          context 'when the entity has many associations' do
            let(:expected) { super().merge(container_id: container.id) }

            before(:example) do
              instance.container = container
              instance.material  = alloyed_material
              instance.variants  = variants
            end

            it { expect(instance.normalize).to be == expected }

            describe 'with associations: { container: true }' do
              let(:expected) { super().merge(container: container_properties) }

              it 'should normalize the association' do
                expect(instance.normalize(associations: { container: true }))
                  .to be == expected
              end
            end

            describe 'with associations: { material: true }' do
              let(:expected) { super().merge(material: alloyed_properties) }

              it 'should normalize the association' do
                expect(instance.normalize(associations: { material: true }))
                  .to be == expected
              end
            end

            describe 'with associations: { material: { elements } }' do
              let(:expected) do
                super().merge(
                  material:
                    alloyed_properties.merge(elements: element_properties)
                )
              end

              it 'should normalize the association' do
                keywords = {
                  associations: {
                    material: {
                      associations: { elements: true }
                    }
                  }
                }

                expect(instance.normalize(keywords)).to be == expected
              end
            end

            describe 'with associations: { variants: true }' do
              let(:expected) { super().merge(variants: variant_properties) }

              it 'should normalize the association' do
                expect(instance.normalize(associations: { variants: true }))
                  .to be == expected
              end
            end

            describe 'with associations: { container, material, variants }' do
              let(:expected) do
                super().merge(
                  container: container_properties,
                  material:
                    alloyed_properties.merge(elements: element_properties),
                  variants:  variant_properties
                )
              end

              it 'should normalize the association' do
                keywords = {
                  associations: {
                    container: true,
                    material: {
                      associations: { elements: true }
                    },
                    variants: true
                  }
                }

                expect(instance.normalize(keywords)).to be == expected
              end
            end
          end
        end
      end
    end
  end
end
