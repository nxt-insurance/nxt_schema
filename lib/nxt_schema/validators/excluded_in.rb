module NxtSchema
  module Validators
    class Excluded < Validator
      def initialize(target)
        @target = target
      end

      register_as :excluded_in
      attr_reader :target

      def build
        lambda do |application, value|
          if target.exclude?(value)
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
