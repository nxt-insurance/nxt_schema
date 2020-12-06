module NxtSchema
  module Validators
    class LessThanOrEqual < Validator
      def initialize(threshold)
        @threshold = threshold
      end

      register_as :less_than_or_equal, :lt_or_eql
      attr_reader :threshold

      def build
        lambda do |node, value|
          if value <= threshold
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
