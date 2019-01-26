# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'support/examples/entities'

module Support::Examples::Entities
  module NormalizationExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when the entity class has an attribute with a custom ' \
                   'transform' \
    do
      example_class 'Spec::Point', Struct.new(:x, :y)

      example_class 'Spec::PointTransform', Bronze::Transform do |klass|
        klass.send(:define_method, :denormalize) do |coords|
          return nil if coords.nil?

          Spec::Point.new(*coords)
        end

        klass.send(:define_method, :normalize) do |point|
          return nil if point.nil?

          [point.x, point.y]
        end
      end

      before(:example) do
        described_class.attribute :coordinates,
          Spec::Point,
          transform: Spec::PointTransform
      end
    end

    shared_examples 'should implement the Normalization methods' do
      describe '::denormalize' do
        let(:expected) { {} }

        it { expect(entity_class).to respond_to(:denormalize).with(1).argument }

        describe 'with nil' do
          let(:error_message) do
            'expected attributes to be a Hash, but was nil'
          end

          it 'should raise an error' do
            expect { entity_class.denormalize(nil) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an empty hash' do
          it { expect(entity_class.denormalize({})).to be_a entity_class }

          it 'should denormalize the attributes' do
            expect(entity_class.denormalize({}).attributes).to be >= expected
          end
        end

        describe 'with a hash with invalid string keys' do
          let(:mystery) do
            'Princess Pink, in the Playroom, with the Squeaky Mallet'
          end
          let(:error_message) { 'invalid attribute "mystery"' }
          let(:attributes)    { { 'mystery' => mystery } }

          it 'should raise an error' do
            expect { entity_class.denormalize(attributes) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with a hash with invalid symbol keys' do
          let(:mystery) do
            'Princess Pink, in the Playroom, with the Squeaky Mallet'
          end
          let(:error_message) { 'invalid attribute :mystery' }
          let(:attributes)    { { mystery: mystery } }

          it 'should raise an error' do
            expect { entity_class.denormalize(attributes) }
              .to raise_error ArgumentError, error_message
          end
        end

        wrap_context 'when the entity class has many attributes' do
          describe 'with nil' do
            let(:error_message) do
              'expected attributes to be a Hash, but was nil'
            end

            it 'should raise an error' do
              expect { entity_class.denormalize(nil) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with an empty hash' do
            let(:expected) do
              {
                title:            nil,
                page_count:       nil,
                publication_date: nil
              }
            end

            it { expect(entity_class.denormalize({})).to be_a entity_class }

            it 'should denormalize the attributes' do
              expect(entity_class.denormalize({}).attributes).to be >= expected
            end
          end

          describe 'with a hash with invalid string keys' do
            let(:mystery) do
              'Princess Pink, in the Playroom, with the Squeaky Mallet'
            end
            let(:error_message) { 'invalid attribute "mystery"' }
            let(:attributes)    { { 'mystery' => mystery } }

            it 'should raise an error' do
              expect { entity_class.denormalize(attributes) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with a hash with invalid symbol keys' do
            let(:mystery) do
              'Princess Pink, in the Playroom, with the Squeaky Mallet'
            end
            let(:error_message) { 'invalid attribute :mystery' }
            let(:attributes)    { { mystery: mystery } }

            it 'should raise an error' do
              expect { entity_class.denormalize(attributes) }
                .to raise_error ArgumentError, error_message
            end
          end

          describe 'with a hash with valid string keys' do
            let(:attributes) do
              {
                'title'      => 'The Lay of Beleriand',
                'page_count' => 500
              }
            end
            let(:expected) do
              {
                title:            attributes['title'],
                page_count:       attributes['page_count'],
                publication_date: nil
              }
            end

            it 'should return an instance of the entity class' do
              expect(entity_class.denormalize(attributes)).to be_a entity_class
            end

            it 'should denormalize the attributes' do
              expect(entity_class.denormalize(attributes).attributes)
                .to be >= expected
            end
          end

          describe 'with a hash with valid symbol keys' do
            let(:attributes) do
              {
                title:      'The Lay of Beleriand',
                page_count: 500
              }
            end
            let(:expected) do
              {
                title:            attributes[:title],
                page_count:       attributes[:page_count],
                publication_date: nil
              }
            end

            it 'should return an instance of the entity class' do
              expect(entity_class.denormalize(attributes)).to be_a entity_class
            end

            it 'should denormalize the attributes' do
              expect(entity_class.denormalize(attributes).attributes)
                .to be >= expected
            end
          end
        end

        wrap_context 'when the entity class has an attribute with a custom ' \
                     'transform' \
        do
          describe 'with an empty hash' do
            it { expect(entity_class.denormalize({})).to be_a entity_class }

            it 'should denormalize the attributes' do
              expect(entity_class.denormalize({}).attributes).to be >= expected
            end
          end

          describe 'with attribute: nil' do
            let(:attributes) { { coordinates: nil } }

            it 'should return an instance of the entity class' do
              expect(entity_class.denormalize(attributes)).to be_a entity_class
            end

            it 'should denormalize the attribute' do
              expect(entity_class.denormalize(attributes).coordinates).to be nil
            end
          end

          describe 'with attribute: value' do
            let(:attributes) { { coordinates: [3, 4] } }

            it 'should return an instance of the entity class' do
              expect(entity_class.denormalize(attributes)).to be_a entity_class
            end

            it 'should denormalize the attribute', :aggregate_failures do
              point = entity_class.denormalize(attributes).coordinates

              expect(point).to be_a Spec::Point
              expect(point.x).to be 3
              expect(point.y).to be 4
            end
          end
        end
      end

      describe '#normalize' do
        let(:tools) { SleepingKingStudios::Tools::Toolbelt.instance }
        let(:expected) do
          tools.hash.convert_keys_to_strings(expected_attributes)
        end

        it { expect(entity).to respond_to(:normalize).with(0).arguments }

        it { expect(entity.normalize).to match_attributes expected }

        wrap_context 'when the entity class has many attributes' do
          it { expect(entity.normalize).to match_attributes expected }

          context 'when the entity is initialized with attributes' do
            let(:initial_attributes) do
              super().merge(
                title:            'The Once And Future King',
                publication_date: Date.new(1958, 1, 1)
              )
            end
            let(:expected) do
              transform = Bronze::Transforms::Attributes::DateTransform.instance
              date      =
                transform.normalize(initial_attributes[:publication_date])

              super().merge('publication_date' => date)
            end

            it { expect(entity.normalize).to match_attributes expected }
          end
        end

        wrap_context 'when the entity class has an attribute with a custom ' \
                     'transform' \
        do
          it { expect(entity.normalize).to match_attributes expected }

          context 'when the entity is initialized with attributes' do
            let(:coordinates) { Spec::Point.new(3, 4) }
            let(:initial_attributes) do
              super().merge(coordinates: coordinates)
            end
            let(:expected) do
              super().merge('coordinates' => [3, 4])
            end

            it { expect(entity.normalize).to match_attributes expected }
          end
        end
      end
    end
  end
end
