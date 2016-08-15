# spec/bronze/tasks/ci_spec.rb

load 'bronze/tasks/ci.thor'

RSpec.describe Bronze::Tasks::Ci do
  let(:instance) { described_class.new }

  describe '::exit_on_failure?' do
    it 'should define the predicate' do
      expect(described_class).
        to have_predicate(:exit_on_failure?).
        with_value(true)
    end # it
  end # describe

  describe '#default' do
    let(:rspec_results) do
      {
        'example_count' => 5,
        'failure_count' => 0,
        'pending_count' => 0,
        'duration'      => 10.0
      } # end hash
    end # let
    let(:formatted_rspec_results) do
      str = 'RSpec:  '
      str << "#{rspec_results['example_count']} examples"
      str << ', ' << "#{rspec_results['failure_count']} failures"
      str << ', ' << "#{rspec_results['pending_count']} pending"
      str << " in #{rspec_results['duration']} seconds."
    end # let

    it { expect(instance).to respond_to(:default).with(0).arguments }

    it 'should aggregate CI results' do
      expect(instance).to receive(:spec).with(no_args).and_return(rspec_results)

      expect(instance).to receive(:puts) do |output|
        expect(output).to include(formatted_rspec_results)
      end # receive

      instance.default
    end # it

    context 'when there are failing RSpec results' do
      let(:rspec_results) { super().merge 'failure_count' => 2 }

      it 'should aggregate CI results' do
        expect(instance).to receive(:spec).
          with(no_args).
          and_return(rspec_results)

        expect(instance).to receive(:puts) do |output|
          expect(output).to include(formatted_rspec_results)
        end # receive

        expect { instance.default }.
          to raise_error Thor::Error,
            'The following steps failed - rspec'
      end # it
    end # context
  end # describe

  describe '#spec' do
    let(:root_dir)   { File.expand_path(__dir__).split('/spec').first }
    let(:spec_dir)   { File.join root_dir, 'spec' }
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
        with(File.join root_dir, 'tmp/ci/rspec.json').
        and_return(JSON.dump expected_results)
    end # method mock_files

    def mock_rspec
      expect(RSpec::Core::Runner).to receive(:run) do |args|
        expect(args).to be == spec_files + expected_options
      end # receive
    end # method mock_rspec

    it { expect(instance).to respond_to(:spec).with(0).arguments }

    it 'should wrap the RSpec test suite' do
      mock_rspec
      mock_files

      results = instance.spec

      expect(results).to be == expected_results['summary']
    end # it

    context 'with :quiet => true' do
      let(:task_options) { super().merge :quiet => true }

      it 'should wrap the RSpec test suite' do
        mock_rspec
        mock_files

        results = instance.spec

        expect(results).to be == expected_results['summary']
      end # it
    end # context
  end # describe
end # describe
