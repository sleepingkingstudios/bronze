# lib/bronze/tasks/ci.thor

require 'thor'
require 'json'
require 'rspec'

require 'bronze/tasks'

# rubocop:disable Metrics/AbcSize, Metrics/ClassLength
# rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength

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
        ENV['CI'] = 'true'

        failing_steps = []

        rspec_results = rspec

        if rspec_results['failure_count'].positive?
          failing_steps << :rspec
        end # if

        rubocop_results = rubocop

        if rubocop_results['offense_count'].positive?
          failing_steps << :rubocop
        end # if

        output = "\n"
        output << format_rspec_results(rspec_results)
        output << "\n"
        output << format_rubocop_results(rubocop_results)
        output << "\n"
        output << format_simplecov_results(load_simplecov_results)

        puts output

        unless failing_steps.empty?
          array_tools = SleepingKingStudios::Tools::ArrayTools
          message     = 'The following steps failed - '
          message << array_tools.humanize_list(failing_steps.map(&:to_s))

          raise Thor::Error, message, caller
        end # unless
      end # method default

      desc :rspec, 'Runs the RSpec test suite.'
      method_option :quiet,
        :aliases => '-q',
        :desc    => 'Does not write test results to STDOUT.'
      # Runs the spec suite and returns the summary hash. If the --quiet option
      # is not selected, also prints the test results to STDOUT using the
      # documentation formatter.
      #
      # @return [Hash] The spec results.
      def rspec
        $LOAD_PATH << spec_dir unless $LOAD_PATH.include?(spec_dir)

        require 'spec_helper'

        args = spec_files

        args << '--format=documentation' unless options[:quiet]
        args << '--format=json' << '--out=tmp/ci/rspec.json'

        RSpec::Core::Runner.run(args)

        results = JSON.parse File.read(File.join root_dir, 'tmp/ci/rspec.json')

        results['summary']
      end # method rspec

      desc :rubocop, 'Runs a Rubocop code quality report.'
      method_option :quiet,
        :aliases => '-q',
        :desc    => 'Does not write quality report to STDOUT.'
      # Runs RuboCop and returns the summary hash. If the --quiet option is not
      # selected, also prints the quality report to STDOUT using the progress
      # formatter.
      #
      # @return [Hash] The quality summary.
      def rubocop
        require 'rubocop'

        cli  = ::RuboCop::CLI.new
        args = []

        args << '--format' << 'progress' unless options[:quiet]
        args << '--format' << 'json' << '--out' << 'tmp/ci/rubocop.json'

        cli.run(args)

        output  = File.read(File.join root_dir, 'tmp/ci/rubocop.json')
        results = JSON.parse output

        results['summary']
      end # method rubocop

      private

      def colorize str, color
        code =
          case color
          when :red        then 31
          when :green      then 32
          when :yellow     then 33
          when :blue       then 34
          when :pink       then 35
          when :light_blue then 36
          else 0
          end # case

        "\e[#{code}m#{str}\e[0m"
      end # method colorize

      def format_rspec_results results
        color =
          if results['failure_count'] > 0
            :red
          elsif results['pending_count'] > 0
            :yellow
          else
            :green
          end # if-elsif-else

        str = "#{colorize 'RSpec:', color}     "
        str << "#{results['example_count']} examples"
        str << ', ' << "#{results['failure_count']} failures"
        str << ', ' << "#{results['pending_count']} pending"
        str << " in #{results['duration']} seconds."
      end # method format_rspec_results

      def format_rubocop_results results
        color =
          if results['offense_count'] > 0
            :red
          else
            :green
          end # if-elsif-else

        str = "#{colorize 'RuboCop:', color}   "
        str << "#{results['inspected_file_count']} files inspected"
        str << ', ' << "#{results['offense_count']} offenses."
      end # method format_rubocop_results

      def format_simplecov_results results
        if results.nil?
          str = "#{colorize 'SimpleCov:', :red} "
          str << 'Unable to load code coverage report.'

          return str
        end # if

        hsh    = results['metrics']
        missed = hsh['total_lines'] - hsh['covered_lines']
        color  =
          if (hsh['covered_percent'] || 0) < 99.0
            :yellow
          else
            :green
          end # if-elsif-else

        str = "#{colorize 'SimpleCov:', color} "
        str << "#{hsh['total_lines']} lines inspected"
        str << ', ' << "#{missed} lines missed"
        str << ', ' << "#{format '%0.02f', hsh['covered_percent']}% coverage."
      end # method format_simplecov_results

      def load_simplecov_results
        output = File.read(File.join root_dir, 'tmp/ci/coverage.json')

        JSON.parse output
      rescue Errno::ENOENT
        nil
      end # method load_simplecov_results

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

# rubocop:enable Metrics/AbcSize, Metrics/ClassLength
# rubocop:enable Metrics/CyclomaticComplexity, Metrics/MethodLength
