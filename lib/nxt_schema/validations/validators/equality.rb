module NxtSchema
  module Validations
    module Validators
      class Equality < Validator
        def initialize(method, expectation)
          @method = method
          @expectation = expectation
        end

        register_as :equality, :eql
        attr_reader :method, :expectation

        # Query for equality validator(:equality, :size, 3)
        # Query for equality validator(:eql, :size, -> { 3 * 3 * 60 })

        def build
          lambda do |node, value|
            raise ArgumentError, "#{value} does not respond to query: #{method}" unless value.respond_to?(method)

            expected_value = expectation.respond_to?(:call) ? Callable.new(expectation).call(node, value) : expectation

            if value.send(method) == expected_value
              true
            else
              node.add_error("#{value.send(method)} does not equal #{expected_value}")
              false
            end
          end
        end
      end
    end
  end
end
