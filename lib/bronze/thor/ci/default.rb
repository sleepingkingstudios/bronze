# lib/bronze/thor/ci/default.thor

require 'simplecov'

unless SimpleCov.running
  SimpleCov.coverage_dir File.join 'tmp', 'ci'
  SimpleCov.at_exit {}
  SimpleCov.start
end # unless

require 'bronze/thor/ci/default_formatter'
require 'bronze/thor/task'

module Bronze::Thor::Ci
  # Defines a Thor task for running the full CI suite.
  module Default
    extend Bronze::Thor::Task

    # The individual CI steps to run.
    CI_STEPS = %w(rspec rubocop simplecov).freeze

    desc :default, 'Runs the full CI suite.'
    # Runs the full CI suite and prints a summary of the results. If any step
    # fails, raises a Thor::Error after printing the summary to force Thor to
    # exit with a non-zero exit code.
    #
    # @raise Thor::Error if any step fails.
    def default
      ENV['CI'] = 'true'

      suite_results = { 'failing_steps' => [] }

      CI_STEPS.each do |ci_step|
        passed, suite_results[ci_step] = send(:"wrap_#{ci_step}")

        suite_results['failing_steps'] << ci_step unless passed
      end # each

      puts formatter.format_summary(suite_results)

      raise_if_suite_failed! suite_results
    end # method default

    private

    def formatter
      @formatter ||= DefaultFormatter.new
    end # method formatter

    def raise_if_suite_failed! suite_results
      failing_steps = suite_results['failing_steps']

      return if failing_steps.empty?

      array_tools = SleepingKingStudios::Tools::ArrayTools
      message     = 'The following steps failed - '
      message << array_tools.humanize_list(failing_steps)

      raise Thor::Error, message, caller
    end # method failed_suite

    def simplecov
      SimpleCov.result
    end # method simplecov

    def wrap_rspec
      results = rspec
      passed  = !results['failure_count'].positive?

      [passed, results]
    end # method wrap_rspec

    def wrap_rubocop
      results = rubocop
      passed  = !results['offense_count'].positive?

      [passed, results]
    end # method wrap_rubocop

    def wrap_simplecov
      results = simplecov

      [true, results]
    end # method wrap_simplecov
  end # class
end # module
