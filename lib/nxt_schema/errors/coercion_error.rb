module NxtSchema
  module Errors
    class CoercionError < Error
      def initialize(value, type)
        @value = value
        @type = type
      end

      def message
        "Could not coerce '#{humanized_value}' into type: #{type.class}"
      end

      attr_reader :value, :type

      private

      def humanized_value
        value.nil? ? 'nil' : value
      end
    end
  end
end
