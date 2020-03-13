module NxtSchema
  module Validators
    class Equality < Validator
      def initialize(expectation, language:)
        @expectation = expectation
        @language = language
      end

      register_as :equality, :eql
      attr_reader :expectation, :language

      # Query for equality validator(:equality, 3)
      # Query for equality validator(:eql, -> { 3 * 3 * 60 })

      def build
        lambda do |node, value|
          expected_value = expectation.respond_to?(:call) ? Callable.new(expectation).call(node, value) : expectation

          if value == expected_value
            true
          else
            node.add_error("#{value} does not equal #{expected_value}")
            false
          end
        end
      end
    end
  end
end
