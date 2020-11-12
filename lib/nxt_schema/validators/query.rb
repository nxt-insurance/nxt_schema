module NxtSchema
  module Validators
    class Query < Validator
      def initialize(method)
        @method = method
      end

      register_as :query
      attr_reader :method

      # Query a boolean method on you value => application(:test, :String).validate(:query, :good_enough?)
      # => Would be valid if value.good_enough? is truthy

      def build
        lambda do |application, value|
          raise ArgumentError, "#{value} does not respond to query: #{method}" unless value.respond_to?(method)

          if value.send(method)
            true
          else
            message = translate_error(application.locale, value: value, actual: value.send(method), query: method)
            application.add_error(message)
          end
        end
      end
    end
  end
end
