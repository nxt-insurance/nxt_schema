module NxtSchema
  module Validators
    class Equality < Validator
      def initialize(expectation)
        @expectation = expectation
      end

      register_as :equal_to, :eql
      attr_reader :expectation

      # Query for equality validator(:equality, 3)
      # Query for equality validator(:eql, -> { 3 * 3 * 60 })

      def build
        lambda do |application, value|
          expected_value = Callable.new(expectation, nil, value).call

          if value == expected_value
            true
          else
            application.add_error(
              translate_error(
                application.locale,
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
