module NxtSchema
  module Errors
    class CoercionError < Error
      def initialize(value, type)
        @value = value
        @type = type
      end

      def message
        "Could not coerce '#{humanized_value}' into type: #{humanized_type}"
      end

      attr_reader :value, :type

      private

      def humanized_value
        value.nil? ? 'nil' : value
      end

      def humanized_type
        type.is_a?(Class) ? type : type.class
      end
    end
  end
end
