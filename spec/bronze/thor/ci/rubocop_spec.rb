# spec/bronze/thor/ci/rubocop_spec.rb

require 'bronze/thor/ci/rubocop'

RSpec.describe Bronze::Thor::Ci::Rubocop do
  let(:described_class) do
    Class.new(::Thor).tap do |klass|
      klass.send :include, super()
    end # class
  end # let
  let(:instance) { described_class.new }

  describe '::exit_on_failure?' do
    it 'should define the predicate' do
      expect(described_class).
        to have_predicate(:exit_on_failure?).
        with_value(true)
    end # it
  end # describe

  describe '#rubocop' do
    let(:task_options) do
      {}
    end # let
    let(:expected_options) do
      opts = []

      opts << '--format' << 'progress' unless task_options[:quiet]
      opts << '--format' << 'json' << '--out' << 'tmp/ci/rubocop.json'
    end # let
    let(:expected_results) do
      { 'summary' => { 'Greetings' => 'Programs' } }
    end # let

    before(:example) do
      allow(instance).to receive(:options).and_return(task_options)
    end # before

    def mock_files
      allow(File).to receive(:read).
        with(File.join Bronze.gem_path, 'tmp/ci/rubocop.json').
        and_return(JSON.dump expected_results)
    end # method mock_files

    def mock_rubocop
      client = double('cli', :run => nil)

      allow(RuboCop::CLI).to receive(:new).and_return(client)

      expect(client).to receive(:run).with(expected_options)
    end # method mock_rubocop

    it { expect(instance).to respond_to(:rubocop).with(0).arguments }

    it 'should wrap the RuboCop CLI' do
      mock_rubocop
      mock_files

      results = instance.rubocop

      expect(results).to be == expected_results['summary']
    end # it

    context 'with :quiet => true' do
      let(:task_options) { super().merge :quiet => true }

      it 'should wrap the RuboCop CLI' do
        mock_rubocop
        mock_files

        results = instance.rubocop

        expect(results).to be == expected_results['summary']
      end # it
    end # context
  end # describe
end # describe
