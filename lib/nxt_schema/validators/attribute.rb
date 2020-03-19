module NxtSchema
  module Validators
    class Attribute < Validator
      def initialize(method, expectation)
        @method = method
        @expectation = expectation
      end

      register_as :attribute, :attr
      attr_reader :method, :expectation

      # Query any attribute on a value with validator(:attribute, :size, ->(s) { s < 7 })

      def build
        lambda do |node, value|
          raise ArgumentError, "#{value} does not respond to query: #{method}" unless value.respond_to?(method)

          if expectation.call(value.send(method))
            true
          else
            node.add_error("#{value} has invalid #{method} attribute of #{value.send(method)}")


            false
          end
        end
      end
    end
  end
end
