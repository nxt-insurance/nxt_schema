module NxtSchema
  module Validators
    class GreaterThanOrEqual < Validator
      def initialize(threshold)
        @threshold = threshold
      end

      register_as :greater_than_or_equal, :gt_or_eql
      attr_reader :threshold

      def build
        lambda do |application, value|
          if value >= threshold
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
