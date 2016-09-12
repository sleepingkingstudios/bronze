# spec/bronze/thor/ci/rspec_spec.rb

require 'bronze/thor/ci/rspec'

RSpec.describe Bronze::Thor::Ci::RSpec do
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

  describe '#rspec' do
    let(:spec_dir)   { File.join Bronze.gem_path, 'spec' }
    let(:spec_files) { Dir[File.join spec_dir, '**', '*_spec.rb'] }
    let(:task_options) do
      {}
    end # let
    let(:expected_options) do
      opts = []

      opts << '--format=documentation' unless task_options[:quiet]
      opts << '--format=json' << '--out=tmp/ci/rspec.json'
    end # let
    let(:expected_results) do
      { 'summary' => { 'Greetings' => 'Programs' } }
    end # let

    before(:example) do
      allow(instance).to receive(:options).and_return(task_options)
    end # before

    def mock_files
      allow(File).to receive(:read).
        with(File.join Bronze.gem_path, 'tmp/ci/rspec.json').
        and_return(JSON.dump expected_results)
    end # method mock_files

    def mock_rspec
      expect(RSpec::Core::Runner).to receive(:run) do |args|
        expect(args).to be == spec_files + expected_options
      end # receive
    end # method mock_rspec

    it { expect(instance).to respond_to(:rspec).with(0).arguments }

    it 'should wrap the RSpec test suite' do
      mock_rspec
      mock_files

      results = instance.rspec

      expect(results).to be == expected_results['summary']
    end # it

    context 'with :quiet => true' do
      let(:task_options) { super().merge :quiet => true }

      it 'should wrap the RSpec test suite' do
        mock_rspec
        mock_files

        results = instance.rspec

        expect(results).to be == expected_results['summary']
      end # it
    end # context
  end # describe
end # describe
