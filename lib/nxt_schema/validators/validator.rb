module NxtSchema
  module Validators
    class Validator
      def self.register_as(*keys)
        keys.each do |key|
          NxtSchema::Validators::Registry::VALIDATORS.register(key, self)
        end

        define_method('key') { @key ||= keys.first }
      end

      def translate_error(**options)
        ErrorMessages.resolve(key, **options)
      end
    end
  end
end
