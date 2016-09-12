# lib/bronze/thor/ci/rspec_results.rb

require 'bronze/thor/ci'

module Bronze::Thor::Ci
  # @api private
  class RSpecResults
    def initialize
      @summary         = Hash.new { |hsh, key| hsh[key] = 0 }
      @profile         = Hash.new { |hsh, key| hsh[key] = 0.0 }
      @failing_files   = []
      @pending_files   = []
      @spec_file_count = 0
    end # constructor

    attr_reader :failing_files
    attr_reader :pending_files
    attr_reader :profile
    attr_reader :spec_file_count
    attr_reader :summary

    def failure_count
      failing_files.count
    end # method failure_count

    def failing?
      failing_files.count > 0
    end # method failing?

    def passing?
      !(failing? && pending?)
    end # method passing?

    def pending?
      pending_count > 0
    end # method pending?

    def pending_count
      summary['pending_count'].to_i
    end # method pending_count

    def to_hash
      {
        'spec_file_count' => spec_file_count,
        'failure_count'   => failure_count,
        'pending_count'   => pending_count,
        'spec_duration'   => summary['duration'],
        'total_duration'  => profile['suite']
      } # end hash
    end # method to_hash

    def update results
      @spec_file_count += 1

      profile['total'] += results['profile']['total']

      update_failures(results)
      update_pending(results)
      update_summary(results)
    end # method update

    private

    def update_failures results
      return unless results['summary']['failure_count'].to_i > 0

      failing_files << results['file_path'] if results['file_path']
    end # method update_failures

    def update_pending results
      return unless results['summary']['pending_count'].to_i > 0

      pending_files << results['file_path'] if results['file_path']
    end # method update_failures

    def update_summary results
      %w(duration example_count failure_count pending_count).each do |key|
        metric = results['summary'][key]

        summary[key] += metric
      end # each
    end # method update_summary
  end # class
end # module
