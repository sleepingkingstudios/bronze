# frozen_string_literal: true

require 'bronze/entities/attributes'
require 'bronze/entities/normalization'
require 'bronze/transforms/entities/normalize_transform'

RSpec.describe Bronze::Transforms::Entities::NormalizeTransform do
  shared_context 'when attribute types are permitted' do
    let(:permitted_types) { [Date] }
    let(:transform) do
      described_class.new(entity_class, permit: permitted_types)
    end
  end

  subject(:transform) { described_class.new(entity_class) }

  let(:entity_class) { Spec::NormalEntity }

  example_class 'Spec::NormalEntity' do |klass|
    klass.send :include, Bronze::Entities::Attributes
    klass.send :include, Bronze::Entities::Normalization

    klass.attribute :title,            String
    klass.attribute :page_count,       Integer
    klass.attribute :publication_date, Date
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(1).argument
        .and_keywords(:permit)
    end
  end

  describe '#entity_class' do
    include_examples 'should have reader', :entity_class, -> { entity_class }
  end

  describe '::denormalize' do
    describe 'with nil' do
      it { expect(transform.denormalize nil).to be nil }
    end

    describe 'with an Object' do
      let(:object) { Object.new }

      it 'should raise an error' do
        expect { transform.denormalize object }.to raise_error ArgumentError
      end
    end

    describe 'with an empty hash' do
      let(:attributes) { {} }
      let(:entity)     { transform.denormalize(attributes) }

      it { expect(transform.denormalize attributes).to be_a entity_class }

      it { expect(entity.title).to be nil }

      it { expect(entity.page_count).to be nil }

      it { expect(entity.publication_date).to be nil }
    end

    describe 'with an attributes hash' do
      let(:attributes) do
        {
          title:            'The Hobbit',
          page_count:       300,
          publication_date: '1937-09-21'
        }
      end
      let(:entity) { transform.denormalize(attributes) }

      it { expect(transform.denormalize attributes).to be_a entity_class }

      it { expect(entity.title).to be == attributes[:title] }

      it { expect(entity.page_count).to be attributes[:page_count] }

      it 'should set the publication date' do
        expect(entity.publication_date)
          .to be == Date.parse(attributes[:publication_date])
      end

      wrap_context 'when attribute types are permitted' do
        it 'should set the publication date' do
          expect(entity.publication_date)
            .to be == Date.parse(attributes[:publication_date])
        end
      end
    end

    describe 'with a non-normal attributes hash' do
      let(:attributes) do
        {
          title:            'The Hobbit',
          page_count:       300,
          publication_date: Date.new(1937, 9, 21)
        }
      end
      let(:entity) { transform.denormalize(attributes) }

      it { expect(transform.denormalize attributes).to be_a entity_class }

      it { expect(entity.title).to be == attributes[:title] }

      it { expect(entity.page_count).to be attributes[:page_count] }

      it 'should set the publication date' do
        expect(entity.publication_date).to be == attributes[:publication_date]
      end

      wrap_context 'when attribute types are permitted' do
        it 'should set the publication date' do
          expect(entity.publication_date).to be == attributes[:publication_date]
        end
      end
    end

    describe 'with a normalized entity' do
      let(:attributes) do
        {
          title:            'The Hobbit',
          page_count:       300,
          publication_date: Date.new(1937, 9, 21)
        }
      end
      let(:normalized) { transform.normalize(entity_class.new(attributes)) }
      let(:entity)     { transform.denormalize(normalized) }

      it { expect(transform.denormalize normalized).to be_a entity_class }

      it { expect(entity.title).to be == attributes[:title] }

      it { expect(entity.page_count).to be attributes[:page_count] }

      it 'should set the publication date' do
        expect(entity.publication_date).to be == attributes[:publication_date]
      end

      wrap_context 'when attribute types are permitted' do
        it 'should set the publication date' do
          expect(entity.publication_date).to be == attributes[:publication_date]
        end
      end
    end
  end

  describe '#normalize' do
    describe 'with nil' do
      it { expect(transform.normalize nil).to be nil }
    end

    describe 'with an Object' do
      let(:object) { Object.new }

      it 'should raise an error' do
        expect { transform.normalize object }.to raise_error NoMethodError
      end
    end

    describe 'with an entity' do
      let(:attributes) { {} }
      let(:entity)     { entity_class.new(attributes) }
      let(:expected) do
        {
          'title'            => nil,
          'page_count'       => nil,
          'publication_date' => nil
        }
      end

      it { expect(transform.normalize entity).to be == expected }

      wrap_context 'when attribute types are permitted' do
        it { expect(transform.normalize entity).to be == expected }
      end
    end

    describe 'with an entity with attribute values' do
      let(:attributes) do
        {
          title:            'The Hobbit',
          page_count:       300,
          publication_date: Date.new(1937, 9, 21)
        }
      end
      let(:entity) { entity_class.new(attributes) }
      let(:expected) do
        {
          'title'            => attributes[:title],
          'page_count'       => attributes[:page_count],
          'publication_date' => attributes[:publication_date].strftime('%F')
        }
      end

      it { expect(transform.normalize entity).to be == expected }

      wrap_context 'when attribute types are permitted' do
        let(:expected) do
          super().merge('publication_date' => attributes[:publication_date])
        end

        it { expect(transform.normalize entity).to be == expected }
      end
    end
  end

  describe '#permitted_types' do
    include_examples 'should have reader', :permitted_types, -> { be == [] }

    wrap_context 'when attribute types are permitted' do
      it { expect(transform.permitted_types).to be == permitted_types }
    end
  end
end
