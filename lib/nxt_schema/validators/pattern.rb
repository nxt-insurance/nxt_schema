module NxtSchema
  module Validators
    class Pattern < Validator
      def initialize(pattern)
        @pattern = pattern
      end

      register_as :pattern, :format
      attr_reader :pattern

      def build
        lambda do |application, value|
          if value.match(pattern)
            true
          else
            message = translate_error(application.locale, value: value, pattern: pattern)
            application.add_error(message)
            false
          end
        end
      end
    end
  end
end
