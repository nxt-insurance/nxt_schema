module NxtSchema
  module Validations
    class ErrorMessageBuilder
      TRANSLATIONS = YAML.load_file(File.expand_path('../nxt_schema/config/translations/en.yaml', __FILE__))

      include NxtInit
      attr_init :key, :language, :actual, :expected

      def build

      end
    end
  end
end
