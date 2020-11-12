module NxtSchema
  module Validators
    class Includes < Validator
      def initialize(target)
        @target = target
      end

      register_as :includes
      attr_reader :target

      def build
        lambda do |application, value|
          if value.include?(target)
            true
          else
            message = translate_error(application.locale, value: value, target: target)
            application.add_error(message)
          end
        end
      end
    end
  end
end
