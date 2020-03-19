module NxtSchema
  module Validators
    class ErrorMessages
      DEFAULT_PATH = File.expand_path("../error_messages/en.yaml", __FILE__)

      VALUES = { }

      def self.load(path = DEFAULT_PATH)
        VALUES.deep_merge!(YAML.load(ERB.new(File.read(path)).result))
      end

      def self.resolve(key, **options)
        # We resolve an interpolate
      end
    end
  end
end
