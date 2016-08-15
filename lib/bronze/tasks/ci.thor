# lib/bronze/tasks/ci.thor

require 'thor'
require 'json'
require 'rspec'

require 'bronze/tasks'

module Bronze
  module Tasks
    # Thor tasks for running in a Continuous Integration environment.
    class Ci < Thor
      namespace :"bronze:ci"

      # Configures Thor so that on an uncaught error, the Thor process exits
      # with status code 1, indicating a failure.
      #
      # @return [True] True.
      def self.exit_on_failure?
        true
      end # class method exit_on_failure?

      # rubocop:disable Metrics/MethodLength
      desc :default, 'Runs the full CI suite.'
      method_option :quiet,
        :aliases => '-q',
        :desc    => 'Does not write test results to STDOUT.'
      # Runs the full CI suite and prints a summary of the results. If any step
      # fails, raises a Thor::Error after printing the summary to force Thor to
      # exit with a non-zero exit code.
      #
      # @raise Thor::Error if any step fails.
      def default
        failing_steps = []

        rspec_results = spec

        if rspec_results['failure_count'].positive?
          failing_steps << :rspec
        end # if

        puts format_rspec_results(rspec_results)

        unless failing_steps.empty?
          array_tools = SleepingKingStudios::Tools::ArrayTools
          message     = 'The following steps failed - '
          message << array_tools.humanize_list(failing_steps.map(&:to_s))

          raise Thor::Error, message, caller
        end # unless
      end # method default
      # rubocop:enable Metrics/MethodLength

      # rubocop:disable Metrics/AbcSize

      desc :spec, 'Runs the RSpec test suite.'
      method_option :quiet,
        :aliases => '-q',
        :desc    => 'Does not write test results to STDOUT.'
      # Runs the spec suite and returns the summary hash. If the --quiet option
      # is not selected, also prints the test results to STDOUT using the
      # documentation formatter.
      #
      # @return [Hash] The spec results.
      def spec
        $LOAD_PATH << spec_dir unless $LOAD_PATH.include?(spec_dir)

        require 'spec_helper'

        args = spec_files

        args << '--format=documentation' unless options[:quiet]
        args << '--format=json' << '--out=tmp/ci/rspec.json'

        RSpec::Core::Runner.run(args)

        out = JSON.parse File.read(File.join root_dir, 'tmp/ci/rspec.json')

        out['summary']
      end # method spec
      # rubocop:enable Metrics/AbcSize

      private

      def format_rspec_results results
        str = 'RSpec:  '
        str << "#{results['example_count']} examples"
        str << ', ' << "#{results['failure_count']} failures"
        str << ', ' << "#{results['pending_count']} pending"
        str << " in #{results['duration']} seconds."
      end # method format_rspec_results

      def root_dir
        @root_dir ||= File.expand_path(__dir__).split('/lib').first
      end # method root_dir

      def spec_dir
        @spec_dir = File.join root_dir, 'spec'
      end # method spec_dir

      def spec_files
        Dir[File.join spec_dir, '**', '*_spec.rb']
      end # method require_spec_files
    end # class
  end # module
end # module
