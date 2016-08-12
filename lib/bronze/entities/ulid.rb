# lib/bronze/entities/ulid.rb

require 'bronze/entities'

require 'sysrandom'

module Bronze::Entities
  # Universally Unique Lexicographically Sortable Identifier.
  #
  # @see https://github.com/alizain/ulid
  # @see https://github.com/rafaelsales/ulid
  module Ulid
    # The encoding used to pack ULIDs. Contains Crockford's base32 (5 bits per
    # character) ordered by ASCII code points, so encoded numbers are sortable
    # as strings in order of numeric value.
    ENCODING = '0123456789ABCDEFGHJKMNPQRSTVWXYZ'.freeze
    REVERSED =
      ENCODING.split('').each.with_index.with_object({}) do |(char, i), hsh|
        hsh[char] = i
      end. # each with object
      freeze
    private_constant :REVERSED

    class << self
      # Generates a ULID.
      #
      # Encodes a 48-bit timestamp and an 80-bit random value as a string with a
      # lexographically ordered 32-character encoding. This guarantees that
      # ULIDs will sort in ascending order by timestamp and by random value.
      #
      # In addition, each ULID after the first generated in each millisecond
      # increments the last random value, ensuring that ULIDs with a matching
      # timestamp from the same generator will sort in order of creation. The
      # highest random bit is reserved, for 79 bits of randomness (minimum
      # 6.04E+23 unique ULIDs per millisecond).
      #
      # @return [String] A unique, sortable identifier.
      #
      # @see http://www.crockford.com/wrmg/base32.html
      def generate
        now = (Time.now.to_f * 1000.0).round
        buf = ''

        generate_random(now, buf)
        generate_timestamp(now, buf)

        buf.reverse
      end # method generate

      private

      # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      #
      # Optimized for performance rather than readability.
      def generate_random now, buf
        len = ENCODING.length

        if @last_timestamp == now
          chars = @last_value.split('').map { |c| REVERSED[c] }
          0.upto(chars.length) do |i|
            char = chars[i]

            if char == len - 1
              chars[i] = 0
            else
              chars[i] = char + 1

              break
            end # if-else
          end # length

          chars.each { |char| buf << ENCODING[char] }
        else
          @last_timestamp = now

          15.times { buf << ENCODING[Sysrandom.random_number(len)] }

          buf << ENCODING[Sysrandom.random_number(len - 1)]
        end # if-else

        @last_value = buf[-16..-1]
      end # method generate_random
      # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

      def generate_timestamp now, buf
        len = ENCODING.length

        10.times do
          mod = now % len
          now = (now - mod) / len

          buf << ENCODING[mod]
        end # times

        buf
      end # method generate_timestamp
    end # eigenclass
  end # module
end # module
