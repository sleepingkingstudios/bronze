# frozen_string_literal: true

require 'bronze'

module Bronze
  # Exception subclass to indicate an intended method has not been implemented
  # on the receiver.
  class NotImplementedError < StandardError
    # @param receiver [Object] The object receiving the message.
    # @param method_name [String] The name of the expected method.
    def initialize(receiver, method_name)
      receiver_message =
        receiver.is_a?(Module) ? "#{receiver}." : "#{receiver.class}#"

      super("#{receiver_message}#{method_name} is not implemented")
    end
  end
end
