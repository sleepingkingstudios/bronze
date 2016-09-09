# lib/bronze/thor/formatter.rb

require 'bronze/thor'

module Bronze::Thor
  # @api private
  class Formatter
    COLORS = {
      :red        => 31,
      :green      => 32,
      :yellow     => 33
    }.freeze

    def colorize str, color
      "\e[#{COLORS.fetch color, 0}m#{str}\e[0m"
    end # method colorize
  end # class Formatter
end # module
