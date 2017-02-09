# spec/bronze/utilities/hash_filter_spec.rb

require 'bronze/utilities/hash_filter'

RSpec.describe Bronze::Utilities::HashFilter do
  shared_context 'when the selector has simple values' do
    let(:selector) { { :title => 'The Lion, The Witch, and the Wardrobe' } }
    let(:subhash)  { selector }
    let(:filters)  { {} }
  end # shared_context

  shared_context 'when the selector has nested hash values' do
    let(:selector) do
      { :series => { :title => 'The Chronicles of Narnia' } }
    end # let
    let(:subhash) { selector }
    let(:filters) { {} }
  end # shared_context

  shared_context 'when the selector has filter values' do
    let(:selector) do
      {
        :author => { :__eq => 'C. S. Lewis' },
        :title  => {
          :__in => ['Prince Caspian', 'Voyage of the Dawn Treader']
        } # end title
      } # end selector
    end # let
    let(:subhash) { {} }
    let(:filters) do
      {
        [:title] => [
          [:__in, ['Prince Caspian', 'Voyage of the Dawn Treader']]
        ], # end array
        [:author] => [
          [:__eq, 'C. S. Lewis']
        ] # end array
      } # end filters
    end # let
  end # shared_context

  shared_context 'when the selector has mixed simple and filter values' do
    let(:selector) do
      {
        :author => 'C. S. Lewis',
        :title  => {
          :__in => ['Prince Caspian', 'Voyage of the Dawn Treader']
        } # end title
      } # end selector
    end # let
    let(:subhash) { { :author => 'C. S. Lewis' } }
    let(:filters) do
      {
        [:title] => [
          [:__in, ['Prince Caspian', 'Voyage of the Dawn Treader']]
        ] # end array
      } # end filters
    end # let
  end # shared_context

  let(:selector) { {} }
  let(:instance) { described_class.new selector }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#filters' do
    include_examples 'should have reader', :filters, ->() { be == {} }

    wrap_context 'when the selector has simple values' do
      it { expect(instance.filters).to be == filters }
    end # wrap_context

    wrap_context 'when the selector has nested hash values' do
      it { expect(instance.filters).to be == filters }
    end # wrap_context

    wrap_context 'when the selector has filter values' do
      it { expect(instance.filters).to be == filters }
    end # wrap_context

    wrap_context 'when the selector has mixed simple and filter values' do
      it { expect(instance.filters).to be == filters }
    end # wrap_context
  end # describe

  describe '#matches?' do
    it { expect(instance).to respond_to(:matches?).with(1).argument }

    describe 'with an empty hash' do
      it { expect(instance.matches?({})).to be true }
    end # describe

    describe 'with a non-empty hash' do
      let(:data) do
        {
          :title  => 'The Lion, The Witch, and the Wardrobe',
          :author => 'C. S. Lewis'
        } # end data
      end # let

      it { expect(instance.matches? data).to be true }
    end # describe

    wrap_context 'when the selector has simple values' do
      describe 'with an empty hash' do
        it { expect(instance.matches?({})).to be false }
      end # describe

      describe 'with a non-matching hash' do
        let(:data) do
          {
            :title  => 'The Silver Chair',
            :author => 'C. S. Lewis'
          } # end data
        end # let

        it { expect(instance.matches? data).to be false }
      end # describe

      describe 'with a matching hash' do
        let(:data) do
          {
            :title  => 'The Lion, The Witch, and the Wardrobe',
            :author => 'C. S. Lewis'
          } # end data
        end # let

        it { expect(instance.matches? data).to be true }
      end # describe
    end # wrap-context

    wrap_context 'when the selector has filter values' do
      describe 'with an empty hash' do
        it { expect(instance.matches?({})).to be false }
      end # describe

      describe 'with a non-matching hash' do
        let(:data) do
          {
            :title  => 'The Silver Chair',
            :author => 'Clive Staples Lewis'
          } # end data
        end # let

        it { expect(instance.matches? data).to be false }
      end # describe

      describe 'with a partially matching hash' do
        let(:data) do
          {
            :title  => 'The Silver Chair',
            :author => 'C. S. Lewis'
          } # end data
        end # let

        it { expect(instance.matches? data).to be false }
      end # describe

      describe 'with a matching hash' do
        let(:data) do
          {
            :title  => 'Prince Caspian',
            :author => 'C. S. Lewis'
          } # end data
        end # let

        it { expect(instance.matches? data).to be true }
      end # describe
    end # wrap_context

    wrap_context 'when the selector has mixed simple and filter values' do
      describe 'with an empty hash' do
        it { expect(instance.matches?({})).to be false }
      end # describe

      describe 'with a non-matching hash' do
        let(:data) do
          {
            :title  => 'The Silver Chair',
            :author => 'Clive Staples Lewis'
          } # end data
        end # let

        it { expect(instance.matches? data).to be false }
      end # describe

      describe 'with a hash matching the subhash' do
        let(:data) do
          {
            :title  => 'The Silver Chair',
            :author => 'C. S. Lewis'
          } # end data
        end # let

        it { expect(instance.matches? data).to be false }
      end # describe

      describe 'with a hash matching the filters' do
        let(:data) do
          {
            :title  => 'Prince Caspian',
            :author => 'Clive Staples Lewis'
          } # end data
        end # let

        it { expect(instance.matches? data).to be false }
      end # describe

      describe 'with a matching hash' do
        let(:data) do
          {
            :title  => 'Prince Caspian',
            :author => 'C. S. Lewis'
          } # end data
        end # let

        it { expect(instance.matches? data).to be true }
      end # describe
    end # wrap_context
  end # describe

  describe '#selector' do
    include_examples 'should have reader', :selector, ->() { be == selector }

    wrap_context 'when the selector has simple values' do
      it { expect(instance.selector).to be == selector }
    end # wrap_context

    wrap_context 'when the selector has nested hash values' do
      it { expect(instance.selector).to be == selector }
    end # wrap_context

    wrap_context 'when the selector has filter values' do
      it { expect(instance.selector).to be == selector }
    end # wrap_context

    wrap_context 'when the selector has mixed simple and filter values' do
      it { expect(instance.selector).to be == selector }
    end # wrap_context
  end # describe

  describe '#subhash' do
    include_examples 'should have reader', :subhash, ->() { be == {} }

    wrap_context 'when the selector has simple values' do
      it { expect(instance.subhash).to be == subhash }
    end # wrap_context

    wrap_context 'when the selector has nested hash values' do
      it { expect(instance.subhash).to be == subhash }
    end # wrap_context

    wrap_context 'when the selector has filter values' do
      it { expect(instance.subhash).to be == subhash }
    end # wrap_context

    wrap_context 'when the selector has mixed simple and filter values' do
      it { expect(instance.subhash).to be == subhash }
    end # wrap_context
  end # describe
end # describe
