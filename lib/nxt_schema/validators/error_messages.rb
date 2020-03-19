module NxtSchema
  module Validators
    class ErrorMessages
      DEFAULT_PATH = File.expand_path("../error_messages/en.yaml", __FILE__)

      VALUES = { }.with_indifferent_access

      def self.load(path = DEFAULT_PATH)
        values = YAML.load(ERB.new(File.read(path)).result).with_indifferent_access
        VALUES.deep_merge!(values)
      end

      def self.resolve(locale, key, **options)
        message = begin
          VALUES.fetch(locale).fetch(key)
        rescue KeyError
          raise "Could not resolve error message for #{locale}->#{key}"
        end

        message % options
      end
    end
  end
end
