module NxtSchema
  module Validators
    class Excludes < Validator
      def initialize(target)
        @target = target
      end

      register_as :excludes
      attr_reader :target

      def build
        lambda do |application, value|
          if value.exclude?(target)
            true
          else
            message = translate_error(application.locale, target: target, value: value)
            application.add_error(message)
          end
        end
      end
    end
  end
end
