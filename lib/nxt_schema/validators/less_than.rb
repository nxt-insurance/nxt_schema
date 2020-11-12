module NxtSchema
  module Validators
    class LessThan < Validator
      def initialize(threshold)
        @threshold = threshold
      end

      register_as :less_than
      attr_reader :threshold

      def build
        lambda do |application, value|
          if value < threshold
            true
          else
            message = translate_error(application.locale, value: value, threshold: threshold)
            application.add_error(message)
          end
        end
      end
    end
  end
end
