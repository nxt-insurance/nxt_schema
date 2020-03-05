module NxtSchema
  module Validators
      class Query < Validator
        def initialize(method)
          @method = method
        end

        register_as :query
        attr_reader :method

        # Query a boolean method on you value => node(:test, :String).validate(:query, :good_enough?)
        # => Would be valid if value.good_enough? is truthy

        def build
          lambda do |node, value|
            raise ArgumentError, "#{value} does not respond to query: #{method}" unless value.respond_to?(method)

            if value.send(method)
              true
            else
              node.add_error("#{value}.#{method} returned #{value.send(method)}")
              false
            end
          end
        end
      end
    end
end
