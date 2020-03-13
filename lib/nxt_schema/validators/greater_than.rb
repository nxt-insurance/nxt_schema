module NxtSchema
  module Validators
    class GreaterThan < Validator
      def initialize(threshold, language:)
        @threshold = threshold
        @language = language
      end

      register_as :greater_than
      attr_reader :threshold, :language

      def build
        lambda do |node, value|
          if value > threshold
            true
          else
            node.add_error("#{value} should be greater than #{threshold}")
            false
          end
        end
      end
    end
  end
end
