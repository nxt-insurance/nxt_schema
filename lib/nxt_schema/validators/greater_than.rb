module NxtSchema
  module Validators
    class GreaterThan < Validator
      def initialize(threshold)
        @threshold = threshold
      end

      register_as :greater_than
      attr_reader :threshold

      def build
        lambda do |node, value|
          if value > threshold
            true
          else
            message = translate_error(node.locale, value: value, threshold: threshold)
            node.add_error(message)
          end
        end
      end
    end
  end
end
