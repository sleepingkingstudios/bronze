# frozen_string_literal: true

require 'support/entities/rare_book'

RSpec.describe Spec::RareBook do
  subject(:rare_book) { described_class.new(initial_attributes) }

  let(:default_attributes) do
    {
      title:            nil,
      isbn:             nil,
      introduction:     described_class.attributes[:introduction].default,
      rarity:           nil,
      page_count:       nil,
      publication_date: nil,
      subtitle:         nil
    }
  end
  let(:initial_attributes) do
    {
      title:            'The Hobbit',
      isbn:             '978-3-16-148410-0',
      rarity:           'medium-rare',
      page_count:       250,
      publication_date: Date.new(1937, 9, 21)
    }
  end

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end

  describe '::attributes' do
    it { expect(described_class).to respond_to(:attributes).with(0).arguments }

    describe 'with :banned_date' do
      it { expect(described_class.attributes[:banned_date]).to be nil }
    end

    describe 'with :id' do
      let(:metadata) { described_class.attributes[:id] }

      it { expect(metadata).to be_a Bronze::Entities::Attributes::Metadata }

      it { expect(metadata.name).to be :id }

      it { expect(metadata.type).to be String }

      it { expect(metadata.allow_nil?).to be false }

      it { expect(metadata.default?).to be true }

      it { expect(metadata.default).to be_a String }

      it { expect(metadata.foreign_key?).to be false }

      it { expect(metadata.primary_key?).to be true }

      it { expect(metadata.read_only?).to be true }

      it { expect(metadata.transform?).to be false }
    end

    describe 'with :introduction' do
      let(:metadata) { described_class.attributes[:introduction] }

      it { expect(metadata).to be_a Bronze::Entities::Attributes::Metadata }

      it { expect(metadata.name).to be :introduction }

      it { expect(metadata.type).to be String }

      it { expect(metadata.allow_nil?).to be false }

      it { expect(metadata.default?).to be true }

      it { expect(metadata.default).to be == default_attributes[:introduction] }

      it { expect(metadata.foreign_key?).to be false }

      it { expect(metadata.primary_key?).to be false }

      it { expect(metadata.read_only?).to be false }

      it { expect(metadata.transform?).to be false }
    end

    describe 'with :isbn' do
      let(:metadata) { described_class.attributes[:isbn] }

      it { expect(metadata).to be_a Bronze::Entities::Attributes::Metadata }

      it { expect(metadata.name).to be :isbn }

      it { expect(metadata.type).to be String }

      it { expect(metadata.allow_nil?).to be false }

      it { expect(metadata.default?).to be false }

      it { expect(metadata.foreign_key?).to be false }

      it { expect(metadata.primary_key?).to be false }

      it { expect(metadata.read_only?).to be true }

      it { expect(metadata.transform?).to be false }
    end

    describe 'with :page_count' do
      let(:metadata) { described_class.attributes[:page_count] }

      it { expect(metadata).to be_a Bronze::Entities::Attributes::Metadata }

      it { expect(metadata.name).to be :page_count }

      it { expect(metadata.type).to be Integer }

      it { expect(metadata.allow_nil?).to be false }

      it { expect(metadata.default?).to be false }

      it { expect(metadata.foreign_key?).to be false }

      it { expect(metadata.primary_key?).to be false }

      it { expect(metadata.read_only?).to be false }

      it { expect(metadata.transform?).to be false }
    end

    describe 'with :publication_date' do
      let(:metadata) { described_class.attributes[:publication_date] }

      it { expect(metadata).to be_a Bronze::Entities::Attributes::Metadata }

      it { expect(metadata.name).to be :publication_date }

      it { expect(metadata.type).to be Date }

      it { expect(metadata.allow_nil?).to be false }

      it { expect(metadata.default?).to be false }

      it { expect(metadata.foreign_key?).to be false }

      it { expect(metadata.primary_key?).to be false }

      it { expect(metadata.read_only?).to be false }

      it 'should return the transform' do
        expect(metadata.transform)
          .to be_a Bronze::Transforms::Attributes::DateTransform
      end

      it { expect(metadata.transform?).to be true }
    end

    describe 'with :rarity' do
      let(:metadata) { described_class.attributes[:rarity] }

      it { expect(metadata).to be_a Bronze::Entities::Attributes::Metadata }

      it { expect(metadata.name).to be :rarity }

      it { expect(metadata.type).to be String }

      it { expect(metadata.allow_nil?).to be false }

      it { expect(metadata.default?).to be false }

      it { expect(metadata.foreign_key?).to be false }

      it { expect(metadata.primary_key?).to be false }

      it { expect(metadata.read_only?).to be false }

      it { expect(metadata.transform?).to be false }
    end

    describe 'with :subtitle' do
      let(:metadata) { described_class.attributes[:subtitle] }

      it { expect(metadata).to be_a Bronze::Entities::Attributes::Metadata }

      it { expect(metadata.name).to be :subtitle }

      it { expect(metadata.type).to be String }

      it { expect(metadata.allow_nil?).to be true }

      it { expect(metadata.default?).to be false }

      it { expect(metadata.foreign_key?).to be false }

      it { expect(metadata.primary_key?).to be false }

      it { expect(metadata.read_only?).to be false }

      it { expect(metadata.transform?).to be false }
    end

    describe 'with :title' do
      let(:metadata) { described_class.attributes[:title] }

      it { expect(metadata).to be_a Bronze::Entities::Attributes::Metadata }

      it { expect(metadata.name).to be :title }

      it { expect(metadata.type).to be String }

      it { expect(metadata.allow_nil?).to be false }

      it { expect(metadata.default?).to be false }

      it { expect(metadata.foreign_key?).to be false }

      it { expect(metadata.primary_key?).to be false }

      it { expect(metadata.read_only?).to be false }

      it { expect(metadata.transform?).to be false }
    end
  end

  describe '::denormalize' do
    let(:expected) do
      {
        title:            nil,
        isbn:             nil,
        introduction:     nil,
        page_count:       nil,
        publication_date: nil,
        rarity:           nil,
        subtitle:         nil
      }
    end

    describe 'with nil' do
      let(:error_message) do
        'expected attributes to be a Hash, but was nil'
      end

      it 'should raise an error' do
        expect { described_class.denormalize(nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an empty hash' do
      it 'should return an instance of the entity class' do
        expect(described_class.denormalize({})).to be_a described_class
      end

      it 'should denormalize the attributes' do
        expect(described_class.denormalize({}).attributes)
          .to be >= expected
      end

      it 'should generate the primary key' do
        expect(described_class.denormalize({}).primary_key).to be_a String
      end
    end

    describe 'with a hash with invalid string keys' do
      let(:mystery) do
        'Princess Pink, in the Playroom, with the Squeaky Mallet'
      end
      let(:error_message) { 'invalid attribute "mystery"' }
      let(:attributes)    { { 'mystery' => mystery } }

      it 'should raise an error' do
        expect { described_class.denormalize(attributes) }
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
        expect { described_class.denormalize(attributes) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a hash with valid string keys' do
      let(:attributes) do
        {
          'title'            => 'The Hobbit',
          'subtitle'         => 'There And Back Again',
          'page_count'       => 200,
          'publication_date' => '1937-09-21'
        }
      end
      let(:expected) do
        {
          title:            'The Hobbit',
          page_count:       200,
          publication_date: Date.new(1937, 9, 21),
          subtitle:         'There And Back Again'
        }
      end

      it 'should return an instance of the entity class' do
        expect(described_class.denormalize(attributes)).to be_a described_class
      end

      it 'should denormalize the attributes' do
        expect(described_class.denormalize(attributes).attributes)
          .to be >= expected
      end

      it 'should generate the primary key' do
        expect(described_class.denormalize(attributes).primary_key)
          .to be_a String
      end

      # rubocop:disable RSpec/NestedGroups
      context 'when the attributes include a primary key' do
        let(:book_uuid)  { 'a6abad76-b312-435a-a0b4-133a5dd080f9' }
        let(:attributes) { super().merge('id' => book_uuid) }
        let(:expected)   { super().merge(id: book_uuid) }

        it 'should denormalize the attributes' do
          expect(described_class.denormalize(attributes).attributes)
            .to be >= expected
        end
      end
      # rubocop:enable RSpec/NestedGroups
    end

    describe 'with a hash with valid symbol keys' do
      let(:attributes) do
        {
          title:            'The Hobbit',
          subtitle:         'There And Back Again',
          page_count:       200,
          publication_date: '1937-09-21'
        }
      end
      let(:expected) do
        {
          title:            'The Hobbit',
          page_count:       200,
          publication_date: Date.new(1937, 9, 21),
          subtitle:         'There And Back Again'
        }
      end

      it 'should return an instance of the entity class' do
        expect(described_class.denormalize(attributes)).to be_a described_class
      end

      it 'should denormalize the attributes' do
        expect(described_class.denormalize(attributes).attributes)
          .to be >= expected
      end

      it 'should generate the primary key' do
        expect(described_class.denormalize(attributes).primary_key)
          .to be_a String
      end

      # rubocop:disable RSpec/NestedGroups
      context 'when the attributes include a primary key' do
        let(:book_uuid)  { 'a6abad76-b312-435a-a0b4-133a5dd080f9' }
        let(:attributes) { super().merge(id: book_uuid) }
        let(:expected)   { super().merge(id: book_uuid) }

        it 'should denormalize the attributes' do
          expect(described_class.denormalize(attributes).attributes)
            .to be >= expected
        end
      end
      # rubocop:enable RSpec/NestedGroups
    end
  end

  describe '#assign_attributes' do
    describe 'with an empty hash' do
      it 'should not change the attributes' do
        expect { rare_book.assign_attributes({}) }
          .not_to change(rare_book, :attributes)
      end
    end

    describe 'with a hash with valid string keys' do
      let(:attributes) do
        {
          'title'      => 'The Hobbit',
          'rarity'     => 'well-done',
          'subtitle'   => 'There And Back Again',
          'page_count' => 200
        }
      end
      let(:expected_attributes) do
        {
          id:               rare_book.id,
          title:            'The Hobbit',
          introduction:     default_attributes[:introduction],
          isbn:             initial_attributes[:isbn],
          page_count:       200,
          publication_date: initial_attributes[:publication_date],
          rarity:           'well-done',
          subtitle:         'There And Back Again'
        }
      end

      it 'should update the attributes' do
        expect { rare_book.assign_attributes(attributes) }
          .to change(rare_book, :attributes)
          .to be == expected_attributes
      end
    end

    describe 'with a hash with valid symbol keys' do
      let(:attributes) do
        {
          title:      'The Hobbit',
          rarity:     'well-done',
          subtitle:   'There And Back Again',
          page_count: 200
        }
      end
      let(:expected_attributes) do
        {
          id:               rare_book.id,
          title:            'The Hobbit',
          introduction:     default_attributes[:introduction],
          isbn:             initial_attributes[:isbn],
          page_count:       200,
          publication_date: initial_attributes[:publication_date],
          rarity:           'well-done',
          subtitle:         'There And Back Again'
        }
      end

      it 'should update the attributes' do
        expect { rare_book.assign_attributes(attributes) }
          .to change(rare_book, :attributes)
          .to be == expected_attributes
      end
    end
  end

  describe '#attribute?' do
    it { expect(rare_book.attribute? :banned_date).to be false }

    it { expect(rare_book.attribute? :introduction).to be true }

    it { expect(rare_book.attribute? :isbn).to be true }

    it { expect(rare_book.attribute? :page_count).to be true }

    it { expect(rare_book.attribute? :publication_date).to be true }

    it { expect(rare_book.attribute? :rarity).to be true }

    it { expect(rare_book.attribute? :subtitle).to be true }

    it { expect(rare_book.attribute? :title).to be true }
  end

  describe '#attributes' do
    let(:expected) do
      default_attributes
        .merge(initial_attributes)
        .merge(id: rare_book.id)
    end

    it { expect(rare_book.attributes).to be == expected }
  end

  describe '#attributes=' do
    describe 'with an empty hash' do
      let(:expected) do
        {
          id:               rare_book.id,
          title:            nil,
          introduction:     nil,
          isbn:             nil,
          page_count:       nil,
          publication_date: nil,
          rarity:           nil,
          subtitle:         nil
        }
      end

      it 'should update the attributes' do
        expect { rare_book.attributes = {} }
          .to change(rare_book, :attributes)
          .to be == expected
      end
    end

    describe 'with a hash with valid string keys' do
      let(:attributes) do
        {
          'title'      => 'The Hobbit',
          'rarity'     => 'well-done',
          'subtitle'   => 'There And Back Again',
          'page_count' => 200
        }
      end
      let(:expected_attributes) do
        {
          id:               rare_book.id,
          title:            'The Hobbit',
          introduction:     nil,
          isbn:             nil,
          page_count:       200,
          publication_date: nil,
          rarity:           'well-done',
          subtitle:         'There And Back Again'
        }
      end

      it 'should update the attributes' do
        expect { rare_book.attributes = attributes }
          .to change(rare_book, :attributes)
          .to be == expected_attributes
      end
    end

    describe 'with a hash with valid symbol keys' do
      let(:attributes) do
        {
          title:      'The Hobbit',
          rarity:     'well-done',
          subtitle:   'There And Back Again',
          page_count: 200
        }
      end
      let(:expected_attributes) do
        {
          id:               rare_book.id,
          title:            'The Hobbit',
          introduction:     nil,
          isbn:             nil,
          page_count:       200,
          publication_date: nil,
          rarity:           'well-done',
          subtitle:         'There And Back Again'
        }
      end

      it 'should update the attributes' do
        expect { rare_book.attributes = attributes }
          .to change(rare_book, :attributes)
          .to be == expected_attributes
      end
    end
  end

  describe '#id' do
    include_examples 'should have reader',
      :id,
      -> { be_a String }
  end

  describe '#id=' do
    include_examples 'should have private writer', :id=
  end

  describe '#inspect' do
    let(:expected) do
      '#<Spec::RareBook ' \
        "id: #{rare_book.id.inspect}, " \
        "title: #{rare_book.title.inspect}, " \
        "subtitle: #{rare_book.subtitle.inspect}, " \
        "isbn: #{rare_book.isbn.inspect}, " \
        "page_count: #{rare_book.page_count.inspect}, " \
        "publication_date: #{rare_book.publication_date.inspect}, " \
        "introduction: #{rare_book.introduction.inspect}, " \
        "rarity: #{rare_book.rarity.inspect}>"
    end

    it { expect(rare_book.inspect).to be == expected }
  end

  describe '#introduction' do
    include_examples 'should have reader',
      :introduction,
      -> { be == described_class.attributes[:introduction].default }

    context 'when the book is initialized with an introduction' do
      let(:initial_attributes) do
        super().merge(
          introduction: 'It was the best of times, it was the worst of times'
        )
      end

      it 'should return the introduction' do
        expect(rare_book.introduction)
          .to be == initial_attributes[:introduction]
      end
    end
  end

  describe '#introduction=' do
    let(:introduction) { 'It was the best of times, it was the worst of times' }

    include_examples 'should have writer', :introduction=

    it 'should update the introduction' do
      expect { rare_book.introduction = introduction }
        .to change(rare_book, :introduction)
        .to be == introduction
    end
  end

  describe '#isbn' do
    include_examples 'should have reader',
      :isbn,
      -> { be == initial_attributes[:isbn] }
  end

  describe '#isbn=' do
    include_examples 'should have private writer', :isbn=
  end

  describe '#normalize' do
    let(:expected_date) do
      transform = Bronze::Transforms::Attributes::DateTransform.instance

      transform.normalize(rare_book.publication_date)
    end
    let(:tools) do
      SleepingKingStudios::Tools::Toolbelt.instance
    end
    let(:expected) do
      hsh =
        default_attributes
        .merge(initial_attributes)
        .merge(id: rare_book.id)
        .merge(publication_date: expected_date)

      tools.hash.convert_keys_to_strings(hsh)
    end

    it { expect(rare_book.normalize).to be == expected }
  end

  describe '#page_count' do
    include_examples 'should have reader',
      :page_count,
      -> { be == initial_attributes[:page_count] }
  end

  describe '#page_count=' do
    let(:page_count) { 300 }

    include_examples 'should have writer', :page_count=

    it 'should update the page count' do
      expect { rare_book.page_count = page_count }
        .to change(rare_book, :page_count)
        .to be == page_count
    end
  end

  describe '#publication_date' do
    include_examples 'should have reader',
      :publication_date,
      -> { be == initial_attributes[:publication_date] }
  end

  describe '#publication_date=' do
    let(:publication_date) { Date.new(1977, 9, 15) }

    include_examples 'should have writer', :publication_date=

    it 'should update the publication date' do
      expect { rare_book.publication_date = publication_date }
        .to change(rare_book, :publication_date)
        .to be == publication_date
    end
  end

  describe '#rarity' do
    include_examples 'should have reader',
      :rarity,
      -> { be == initial_attributes[:rarity] }
  end

  describe '#rarity=' do
    let(:rarity) { 'well-done' }

    include_examples 'should have writer', :rarity=

    it 'should update the publication date' do
      expect { rare_book.rarity = rarity }
        .to change(rare_book, :rarity)
        .to be == rarity
    end
  end

  describe '#subtitle' do
    include_examples 'should have reader',
      :subtitle,
      -> { be == initial_attributes[:subtitle] }
  end

  describe '#subtitle=' do
    let(:subtitle) { 'There And Back Again' }

    include_examples 'should have writer', :subtitle=

    it 'should update the subtitle' do
      expect { rare_book.subtitle = subtitle }
        .to change(rare_book, :subtitle)
        .to be == subtitle
    end
  end

  describe '#title' do
    include_examples 'should have reader',
      :title,
      -> { be == initial_attributes[:title] }
  end

  describe '#title=' do
    let(:title) { 'The Silmarillion' }

    include_examples 'should have writer', :title=

    it 'should update the title' do
      expect { rare_book.title = title }
        .to change(rare_book, :title)
        .to be == title
    end
  end
end
