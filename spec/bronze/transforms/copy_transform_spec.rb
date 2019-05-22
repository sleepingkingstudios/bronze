# frozen_string_literal: true

require 'bronze/transforms/copy_transform'

RSpec.describe Bronze::Transforms::CopyTransform do
  subject(:transform) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '::instance' do
    it { expect(described_class).to have_reader(:instance) }

    it { expect(described_class.instance).to be_a described_class }

    it 'should return a memoized instance' do
      transform = described_class.instance

      3.times { expect(described_class.instance).to be transform }
    end
  end

  describe '#denormalize' do
    it { expect(transform).to respond_to(:denormalize).with(1).argument }

    describe 'with nil' do
      it { expect(transform.denormalize nil).to be nil }
    end

    describe 'with an Object' do
      let(:object) { Object.new }

      it 'should raise an error' do
        expect { transform.denormalize(object) }
          .to raise_error ArgumentError, 'argument must be a hash'
      end
    end

    describe 'with an attributes hash' do
      let(:attributes) { { id: '0', title: 'The Last Ringbearer' } }

      it { expect(transform.denormalize attributes).to be == attributes }

      it 'should return a copy of the object' do
        copy = transform.denormalize attributes

        expect { copy[:author] = 'Kirill Yeskov' }
          .not_to(change { attributes[:author] })
      end
    end

    describe 'with an attributes hash with nested objects' do
      let(:attributes) do
        {
          author: 'J.R.R. Tolkien',
          series: 'The Lord of the Rings',
          books:  [
            {
              title: 'The Fellowship of the Ring'
            },
            {
              title: 'The Two Towers'
            },
            {
              title: 'The Return of the King'
            }
          ]
        }
      end

      it { expect(transform.denormalize attributes).to be == attributes }

      it 'should return a copy of the object' do
        copy = transform.denormalize attributes

        expect { copy[:author] = 'Kirill Yeskov' }
          .not_to(change { attributes[:author] })
      end

      it 'should return a copy of the nested objects' do
        copy = transform.denormalize attributes

        expect { copy[:books][0][:title] = 'The Hobbit' }
          .not_to(change { attributes[:books][0][:title] })
      end
    end
  end

  describe '#normalize' do
    it { expect(transform).to respond_to(:normalize).with(1).argument }

    describe 'with nil' do
      it { expect(transform.normalize nil).to be nil }
    end

    describe 'with an Object' do
      let(:object) { Object.new }

      it 'should raise an error' do
        expect { transform.normalize(object) }
          .to raise_error ArgumentError, 'argument must be a hash'
      end
    end

    describe 'with an attributes hash' do
      let(:attributes) { { id: '0', title: 'The Last Ringbearer' } }

      it { expect(transform.normalize attributes).to be == attributes }

      it 'should return a copy of the object' do
        copy = transform.normalize attributes

        expect { copy[:author] = 'Kirill Yeskov' }
          .not_to(change { attributes[:author] })
      end
    end

    describe 'with an attributes hash with nested objects' do
      let(:attributes) do
        {
          author: 'J.R.R. Tolkien',
          series: 'The Lord of the Rings',
          books:  [
            {
              title: 'The Fellowship of the Ring'
            },
            {
              title: 'The Two Towers'
            },
            {
              title: 'The Return of the King'
            }
          ]
        }
      end

      it { expect(transform.normalize attributes).to be == attributes }

      it 'should return a copy of the object' do
        copy = transform.normalize attributes

        expect { copy[:author] = 'Kirill Yeskov' }
          .not_to(change { attributes[:author] })
      end

      it 'should return a copy of the nested objects' do
        copy = transform.normalize attributes

        expect { copy[:books][0][:title] = 'The Hobbit' }
          .not_to(change { attributes[:books][0][:title] })
      end
    end
  end
end
