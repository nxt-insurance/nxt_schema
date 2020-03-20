module NxtSchema
  module Validators
    class Pattern < Validator
      def initialize(pattern)
        @pattern = pattern
      end

      register_as :pattern, :format
      attr_reader :pattern

      def build
        lambda do |node, value|
          if value.match(pattern)
            true
          else
            message = translate_error(node.locale, value: value, pattern: pattern)
            node.add_error(message)
            false
          end
        end
      end
    end
  end
end
