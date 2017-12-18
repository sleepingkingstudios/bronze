# spec/bronze/entities/ulid_spec.rb

require 'bronze/entities/ulid'

RSpec.describe Bronze::Entities::Ulid do
  describe '::ENCODING' do
    it { expect(described_class).to have_immutable_constant(:ENCODING) }

    it 'should have 32 characters' do
      expect(described_class::ENCODING.length).to be 32
    end # it

    it 'should encode 0-9 and A-Z, except for I, L, O, and U' do
      expected = [*'0'..'9', *'A'..'Z']
      expected.reject! { |char| 'ILOU'.include?(char) }

      expect(described_class::ENCODING.split '').
        to contain_exactly(*expected)
    end # it

    it 'should be lexographically ordered' do
      chars  = described_class::ENCODING.split ''
      sorted = chars.sort_by(&:ord).join

      expect(sorted).to be == described_class::ENCODING
    end # it
  end # describe

  describe '::new' do
    it { expect(described_class).not_to be_constructible }
  end # describe

  describe '::===' do
    it { expect(described_class).to respond_to(:===).with(1).argument }

    # rubocop:disable Style/CaseEquality

    # rubocop:disable Style/NilComparison
    describe 'with nil' do
      it { expect(described_class === nil).to be false }
    end # describe
    # rubocop:enable Style/NilComparison

    describe 'with an object' do
      it { expect(described_class === Object.new).to be false }
    end # describe

    describe 'with an empty string' do
      it { expect(described_class === '').to be false }
    end # describe

    describe 'with a string that is too short' do
      let(:value) { 'A' * 25 }

      it { expect(described_class === value).to be false }
    end # describe

    describe 'with a string that is too long' do
      let(:value) { 'A' * 27 }

      it { expect(described_class === value).to be false }
    end # describe

    describe 'with a string with invalid characters' do
      let(:value) { 'A' * 25 + '?' }

      it { expect(described_class === value).to be false }
    end # describe

    describe 'with a string with valid characters' do
      let(:value) { 'A' * 26 }

      it { expect(described_class === value).to be true }
    end # describe

    describe 'with a string with lowercase characters' do
      let(:value) { 'a' * 26 }

      it { expect(described_class === value).to be true }
    end # describe

    describe 'with a generated ULID' do
      let(:value) { described_class.generate }

      it { expect(described_class === value).to be true }
    end # describe

    # rubocop:enable Style/CaseEquality
  end # describe

  describe '::generate' do
    it { expect(described_class).to respond_to(:generate).with(0).arguments }

    def decode str
      unpack(str).each.with_index.reduce(0) do |sum, (int, pow)|
        sum + int * (32**pow)
      end # reduce
    end # method decode

    def encode int, len
      ary = []

      len.times do
        mod = int % 32
        int = (int - mod) / 32

        ary << mod
      end # times

      pack ary
    end # method encode

    def pack chars
      chars.map { |char| described_class::ENCODING[char] }.join.reverse
    end # method pack

    # rubocop:disable Metrics/AbcSize
    def stub_rand chars
      chars = unpack(encode chars, 16) if chars.is_a?(Integer)

      allow(Sysrandom).
        to receive(:random_number).
        with(32).
        exactly(15).times.
        and_return(*chars[0...-1])

      allow(Sysrandom).
        to receive(:random_number).
        with(31).
        and_return(chars[-1])
    end # method stub_rand
    # rubocop:enable Metrics/AbcSize

    def unpack str
      ary = str.reverse.split('')
      ary.map { |char| described_class::ENCODING.split('').index(char) }
    end # method unpack

    after(:example) do
      described_class.instance_variable_set(:@last_timestamp, nil)
    end # after

    it 'should generate a ULID' do
      ulid = described_class.generate

      expect(ulid).to be_a String
      expect(ulid.length).to be == 26
    end # it

    it 'should generate a timestamp', :aggregate_failures do
      times = [0, 1]
      ulids = []

      1.upto(7) do |i|
        pow = 32**i

        times << (pow / 2 - 1) << (pow / 2) << (pow - 1) << pow
      end # upto

      times << (32**8 - 1)

      times.each do |time|
        allow(Time).to receive(:now).and_return(0.001 * time)

        ulid      = described_class.generate
        timestamp = ulid[0...10]

        expect(decode timestamp).to be == time

        ulids << ulid
      end # each

      expect(ulids.sort).to be == ulids
    end # it

    it 'should generate a random factor' do
      # rubocop:disable Layout/ExtraSpacing
      chars = [
        20, 10, 24, 16,  0, 24, 22, 25,
        16, 21,  1, 26, 14, 14, 24, 16
      ] # end array
      # rubocop:enable Layout/ExtraSpacing

      stub_rand(chars)

      ulid   = described_class.generate
      random = ulid[-16..-1]

      expect(unpack random).to be == chars
    end # it

    context 'when multiple ulids are generated with the same timestamp' do
      it 'should increment the random factor' do
        time  = 32**7
        rands = [0, 1]

        1.upto(15) do |i|
          pow = 32**i

          rands << (pow / 2 - 1) << (pow / 2) << (pow - 1) << pow
        end # upto

        rands.each do |chars|
          allow(Time).to receive(:now).and_return(0.001 * time)

          stub_rand(chars)

          prev   = described_class.generate
          prev_r = prev[-16..-1]

          succ   = described_class.generate
          succ_r = succ[-16..-1]

          expect(succ).to be > prev
          expect(decode succ_r).to be == (decode(prev_r) + 1)

          time += 1
        end # each
      end # it
    end # context
  end # describe
end # describe
