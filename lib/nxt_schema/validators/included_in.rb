module NxtSchema
  module Validators
    class Included < Validator
      def initialize(target)
        @target = target
      end

      register_as :included_in
      attr_reader :target

      def build
        lambda do |application, value|
          if target.include?(value)
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
