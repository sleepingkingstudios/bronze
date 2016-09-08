# lib/bronze/tasks/ci.thor

require 'simplecov'

unless SimpleCov.running
  SimpleCov.coverage_dir File.join 'tmp', 'ci'
  SimpleCov.at_exit {}
  SimpleCov.start
end # unless

require 'thor'
require 'json'

require 'bronze/tasks'

# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/MethodLength

module Bronze::Tasks
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

      simplecov_results = simplecov

      output = "\n"
      output << format_rspec_results(rspec_results)
      output << "\n"
      output << format_rubocop_results(rubocop_results)
      output << "\n"
      output << format_simplecov_results(simplecov_results)

      puts output

      unless failing_steps.empty?
        array_tools = SleepingKingStudios::Tools::ArrayTools
        message     = 'The following steps failed - '
        message << array_tools.humanize_list(failing_steps.map(&:to_s))

        raise Thor::Error, message, caller
      end # unless
    end # method default

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

      missed = results.total_lines - results.covered_lines
      color  = (results.covered_percent || 0) < 99.0 ? :yellow : :green

      str = "#{colorize 'SimpleCov:', color} "
      str << "#{results.total_lines} lines inspected"
      str << ', ' << "#{missed} lines missed"
      str << ', ' << "#{format '%0.02f', results.covered_percent}% coverage."
    end # method format_simplecov_results

    def root_dir
      @root_dir ||= File.expand_path(__dir__).split('/lib').first
    end # method root_dir

    def simplecov
      SimpleCov.result
    end # method simplecov
  end # class
end # module

# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/CyclomaticComplexity
# rubocop:enable Metrics/MethodLength

require 'bronze/tasks/ci/rspec_tasks'
require 'bronze/tasks/ci/rubocop_tasks'
