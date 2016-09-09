# lib/bronze/thor/ci/default_formatter.rb

require 'bronze/thor/ci'
require 'bronze/thor/formatter'

module Bronze::Thor::Ci
  # @api private
  class DefaultFormatter < Bronze::Thor::Formatter
    def format_rspec_results results
      str = "#{colorize 'RSpec:', rspec_results_color(results)}     "
      str << "#{results['example_count']} examples"
      str << ', ' << "#{results['failure_count']} failures"
      str << ', ' << "#{results['pending_count']} pending"
      str << " in #{results['duration']} seconds."
    end # method format_rspec_results

    def format_rubocop_results results
      str = "#{colorize 'RuboCop:', rubocop_results_color(results)}   "
      str << "#{results['inspected_file_count']} files inspected"
      str << ', ' << "#{results['offense_count']} offenses."
    end # method format_rubocop_results

    def format_simplecov_results results
      return format_missing_simplecov_results if results.nil?

      missed = results.total_lines - results.covered_lines

      str = "#{colorize 'SimpleCov:', simplecov_results_color(results)} "
      str << "#{results.total_lines} lines inspected"
      str << ", #{missed} lines missed"
      str << ", #{format '%0.02f', results.covered_percent}% coverage."
    end # method format_simplecov_results

    def format_summary suite_results
      output = "\n"
      output << format_rspec_results(suite_results['rspec'])
      output << "\n"
      output << format_rubocop_results(suite_results['rubocop'])
      output << "\n"
      output << format_simplecov_results(suite_results['simplecov'])
    end # method format_summary

    private

    def format_missing_simplecov_results
      str = "#{colorize 'SimpleCov:', :red} "
      str << 'Unable to load code coverage report.'
    end # method format_missing_simplecov_results

    def rubocop_results_color results
      if results['offense_count'] > 0
        :red
      else
        :green
      end # if-elsif-else
    end # method rubocop_results_color

    def rspec_results_color results
      if results['failure_count'] > 0
        :red
      elsif results['pending_count'] > 0
        :yellow
      else
        :green
      end # if-elsif-else
    end # method rspec_results_color

    def simplecov_results_color results
      if (results.covered_percent || 0) < 99.0
        :yellow
      else
        :green
      end # if-else
    end # method simplecov_results_color
  end # class
end # module
