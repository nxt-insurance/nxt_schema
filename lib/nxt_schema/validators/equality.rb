module NxtSchema
  module Validators
    class Equality < Validator
      def initialize(expectation)
        @expectation = expectation
      end

      register_as :equality, :eql
      attr_reader :expectation

      # Query for equality validator(:equality, 3)
      # Query for equality validator(:eql, -> { 3 * 3 * 60 })

      def build
        lambda do |node, value|
          expected_value = expectation.respond_to?(:call) ? Callable.new(expectation).call(node, value) : expectation

          if value == expected_value
            true
          else
            node.add_error(
              translate_error(
                node.locale,
                actual: value,
                expected: expected_value
              )
            )
          end
        end
      end
    end
  end
end
