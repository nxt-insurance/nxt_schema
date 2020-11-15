module NxtSchema
  module Validators
    class Validator
      def self.register_as(*keys)
        keys.each do |key|
          NxtSchema::Validators::REGISTRY.register(key, self)
        end

        define_method('key') { @key ||= keys.first }
      end

      def translate_error(locale, **options)
        NxtSchema::Validators::ErrorMessages.resolve(locale, key, **options)
      end
    end
  end
end
