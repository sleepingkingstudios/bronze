# frozen_string_literal: true

require 'support/entities/book'

RSpec.describe Spec::Book do
  subject(:book) { described_class.new(initial_attributes) }

  let(:default_attributes) do
    {
      id:               nil,
      title:            nil,
      isbn:             nil,
      introduction:     described_class.attributes[:introduction].default,
      page_count:       nil,
      publication_date: nil,
      subtitle:         nil
    }
  end
  let(:initial_attributes) do
    {
      title:            'The Hobbit',
      isbn:             '978-3-16-148410-0',
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
    end

    describe 'with :rarity' do
      it { expect(described_class.attributes[:banned_date]).to be nil }
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
    end
  end

  describe '#==' do
    # rubocop:disable Style/NilComparison
    describe 'with nil' do
      it { expect(book == nil).to be false }
    end
    # rubocop:enable Style/NilComparison

    describe 'with an Object' do
      it { expect(book == Object.new).to be false }
    end

    describe 'with an entity with a different class' do
      let(:other_entity_class) { Spec::OtherEntityClass }
      let(:other_entity)       { other_entity_class.new }

      example_class 'Spec::OtherEntityClass' do |klass|
        klass.send :include, Bronze::Entities::Attributes
      end

      it { expect(book == other_entity).to be false }
    end

    describe 'with an instance of a subclass' do
      let(:other_entity_class) { Class.new(described_class) }
      let(:other_entity)       { other_entity_class.new }

      it { expect(book == other_entity).to be false }
    end

    describe 'with a non-matching attributes hash' do
      let(:attributes) { book.attributes.merge(title: 'Green Eggs And Ham') }

      it { expect(book == attributes).to be false }
    end

    describe 'with a matching attributes hash' do
      let(:attributes) { book.attributes }

      it { expect(book == attributes).to be true }
    end

    describe 'with an entity with non-matching attributes' do
      let(:attributes)   { book.attributes.merge(title: 'Green Eggs And Ham') }
      let(:other_entity) { described_class.new(attributes) }

      it { expect(book == other_entity).to be false }
    end

    describe 'with an entity with matching attributes' do
      let(:attributes)   { book.attributes }
      let(:other_entity) { described_class.new(attributes) }

      it { expect(book == other_entity).to be true }
    end
  end

  describe '#assign_attributes' do
    it { expect(book).to respond_to(:assign_attributes).with(1).argument }

    describe 'with nil' do
      let(:error_message) do
        'expected attributes to be a Hash, but was nil'
      end

      it 'should raise an error' do
        expect { book.assign_attributes(nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an empty hash' do
      it 'should not change the attributes' do
        expect { book.assign_attributes({}) }
          .not_to change(book, :attributes)
      end
    end

    describe 'with a hash with invalid string keys' do
      let(:mystery) do
        'Princess Pink, in the Playroom, with the Squeaky Mallet'
      end
      let(:error_message) { 'invalid attribute "mystery"' }
      let(:attributes)    { { 'mystery' => mystery } }

      it 'should raise an error' do
        expect { book.assign_attributes(attributes) }
          .to raise_error ArgumentError, error_message
      end

      # rubocop:disable Lint/HandleExceptions
      # rubocop:disable RSpec/ExampleLength
      it 'should not change the attributes' do
        expect do
          begin
            book.assign_attributes(attributes)
          rescue ArgumentError
          end
        end
          .not_to change(book, :attributes)
      end
      # rubocop:enable Lint/HandleExceptions
      # rubocop:enable RSpec/ExampleLength
    end

    describe 'with a hash with invalid symbol keys' do
      let(:mystery) do
        'Princess Pink, in the Playroom, with the Squeaky Mallet'
      end
      let(:error_message) { 'invalid attribute :mystery' }
      let(:attributes) { { mystery: mystery } }

      it 'should raise an error' do
        expect { book.assign_attributes(attributes) }
          .to raise_error ArgumentError, error_message
      end

      # rubocop:disable Lint/HandleExceptions
      # rubocop:disable RSpec/ExampleLength
      it 'should not change the attributes' do
        expect do
          begin
            book.assign_attributes(attributes)
          rescue ArgumentError
          end
        end
          .not_to change(book, :attributes)
      end
      # rubocop:enable Lint/HandleExceptions
      # rubocop:enable RSpec/ExampleLength
    end

    describe 'with a hash with valid string keys' do
      let(:attributes) do
        {
          'title'      => 'The Hobbit',
          'subtitle'   => 'There And Back Again',
          'page_count' => 200
        }
      end
      let(:expected_attributes) do
        {
          id:               book.id,
          title:            'The Hobbit',
          introduction:     default_attributes[:introduction],
          isbn:             initial_attributes[:isbn],
          page_count:       200,
          publication_date: initial_attributes[:publication_date],
          subtitle:         'There And Back Again'
        }
      end

      it 'should update the attributes' do
        expect { book.assign_attributes(attributes) }
          .to change(book, :attributes)
          .to be == expected_attributes
      end
    end

    describe 'with a hash with valid symbol keys' do
      let(:attributes) do
        {
          title:      'The Hobbit',
          subtitle:   'There And Back Again',
          page_count: 200
        }
      end
      let(:expected_attributes) do
        {
          id:               book.id,
          title:            'The Hobbit',
          introduction:     default_attributes[:introduction],
          isbn:             initial_attributes[:isbn],
          page_count:       200,
          publication_date: initial_attributes[:publication_date],
          subtitle:         'There And Back Again'
        }
      end

      it 'should update the attributes' do
        expect { book.assign_attributes(attributes) }
          .to change(book, :attributes)
          .to be == expected_attributes
      end
    end
  end

  describe '#attribute?' do
    it { expect(book).to respond_to(:attribute?).with(1).argument }

    it { expect(book.attribute? :banned_date).to be false }

    it { expect(book.attribute? :introduction).to be true }

    it { expect(book.attribute? :isbn).to be true }

    it { expect(book.attribute? :page_count).to be true }

    it { expect(book.attribute? :publication_date).to be true }

    it { expect(book.attribute? :rarity).to be false }

    it { expect(book.attribute? :subtitle).to be true }

    it { expect(book.attribute? :title).to be true }
  end

  describe '#attributes' do
    let(:expected) do
      default_attributes
        .merge(initial_attributes)
        .merge(id: book.id)
    end

    it { expect(book).to respond_to(:attributes).with(0).arguments }

    it { expect(book.attributes).to be == expected }
  end

  describe '#attributes=' do
    it { expect(book).to respond_to(:attributes=).with(1).argument }

    describe 'with nil' do
      let(:error_message) do
        'expected attributes to be a Hash, but was nil'
      end

      it 'should raise an error' do
        expect { book.attributes = nil }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an empty hash' do
      let(:expected) do
        {
          id:               book.id,
          title:            nil,
          introduction:     nil,
          isbn:             nil,
          page_count:       nil,
          publication_date: nil,
          subtitle:         nil
        }
      end

      it 'should update the attributes' do
        expect { book.attributes = {} }
          .to change(book, :attributes)
          .to be == expected
      end
    end

    describe 'with a hash with invalid string keys' do
      let(:mystery) do
        'Princess Pink, in the Playroom, with the Squeaky Mallet'
      end
      let(:error_message) { 'invalid attribute "mystery"' }
      let(:attributes)    { { 'mystery' => mystery } }

      it 'should raise an error' do
        expect { book.attributes = attributes }
          .to raise_error ArgumentError, error_message
      end

      # rubocop:disable Lint/HandleExceptions
      # rubocop:disable RSpec/ExampleLength
      it 'should not change the attributes' do
        expect do
          begin
            book.attributes = attributes
          rescue ArgumentError
          end
        end
          .not_to change(book, :attributes)
      end
      # rubocop:enable Lint/HandleExceptions
      # rubocop:enable RSpec/ExampleLength
    end

    describe 'with a hash with invalid symbol keys' do
      let(:mystery) do
        'Princess Pink, in the Playroom, with the Squeaky Mallet'
      end
      let(:error_message) { 'invalid attribute :mystery' }
      let(:attributes)    { { mystery: mystery } }

      it 'should raise an error' do
        expect { book.attributes = attributes }
          .to raise_error ArgumentError, error_message
      end

      # rubocop:disable Lint/HandleExceptions
      # rubocop:disable RSpec/ExampleLength
      it 'should not change the attributes' do
        expect do
          begin
            book.attributes = attributes
          rescue ArgumentError
          end
        end
          .not_to change(book, :attributes)
      end
      # rubocop:enable Lint/HandleExceptions
      # rubocop:enable RSpec/ExampleLength
    end

    describe 'with a hash with valid string keys' do
      let(:attributes) do
        {
          'title'      => 'The Hobbit',
          'subtitle'   => 'There And Back Again',
          'page_count' => 200
        }
      end
      let(:expected_attributes) do
        {
          id:               book.id,
          title:            'The Hobbit',
          introduction:     nil,
          isbn:             nil,
          page_count:       200,
          publication_date: nil,
          subtitle:         'There And Back Again'
        }
      end

      it 'should update the attributes' do
        expect { book.attributes = attributes }
          .to change(book, :attributes)
          .to be == expected_attributes
      end
    end

    describe 'with a hash with valid symbol keys' do
      let(:attributes) do
        {
          title:      'The Hobbit',
          subtitle:   'There And Back Again',
          page_count: 200
        }
      end
      let(:expected_attributes) do
        {
          id:               book.id,
          title:            'The Hobbit',
          introduction:     nil,
          isbn:             nil,
          page_count:       200,
          publication_date: nil,
          subtitle:         'There And Back Again'
        }
      end

      it 'should update the attributes' do
        expect { book.attributes = attributes }
          .to change(book, :attributes)
          .to be == expected_attributes
      end
    end
  end

  describe '#get_attribute' do
    it { expect(book).to respond_to(:get_attribute).with(1).argument }

    describe 'with an invalid attribute name' do
      let(:error_message) { 'invalid attribute :banned_date' }

      it 'should raise an error' do
        expect { book.get_attribute(:banned_date) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a valid attribute name' do
      it 'should return the attribute' do
        expect(book.get_attribute(:title)).to be == initial_attributes[:title]
      end
    end
  end

  describe '#inspect' do
    let(:expected) do
      '#<Spec::Book ' \
        "id: #{book.id.inspect}, " \
        "title: #{book.title.inspect}, " \
        "subtitle: #{book.subtitle.inspect}, " \
        "isbn: #{book.isbn.inspect}, " \
        "page_count: #{book.page_count.inspect}, " \
        "publication_date: #{book.publication_date.inspect}, " \
        "introduction: #{book.introduction.inspect}>"
    end

    it { expect(book.inspect).to be == expected }
  end

  describe '#id' do
    include_examples 'should have reader',
      :id,
      -> { be_a String }
  end

  describe '#id=' do
    include_examples 'should have private writer', :id=
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
        expect(book.introduction).to be == initial_attributes[:introduction]
      end
    end
  end

  describe '#introduction=' do
    let(:introduction) { 'It was the best of times, it was the worst of times' }

    include_examples 'should have writer', :introduction=

    it 'should update the introduction' do
      expect { book.introduction = introduction }
        .to change(book, :introduction)
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

  describe '#page_count' do
    include_examples 'should have reader',
      :page_count,
      -> { be == initial_attributes[:page_count] }
  end

  describe '#page_count=' do
    let(:page_count) { 300 }

    include_examples 'should have writer', :page_count=

    it 'should update the page count' do
      expect { book.page_count = page_count }
        .to change(book, :page_count)
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
      expect { book.publication_date = publication_date }
        .to change(book, :publication_date)
        .to be == publication_date
    end
  end

  describe '#set_attribute' do
    it { expect(book).to respond_to(:set_attribute).with(2).arguments }

    describe 'with an invalid attribute name' do
      let(:error_message) { 'invalid attribute :banned_date' }

      it 'should raise an error' do
        expect { book.set_attribute(:banned_date, Date.today) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a valid attribute name' do
      let(:title) { 'The Silmarillion' }

      it 'should update the attribute' do
        expect { book.set_attribute(:title, title) }
          .to change { book.get_attribute(:title) }
          .to be == title
      end
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
      expect { book.subtitle = subtitle }
        .to change(book, :subtitle)
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
      expect { book.title = title }
        .to change(book, :title)
        .to be == title
    end
  end
end
