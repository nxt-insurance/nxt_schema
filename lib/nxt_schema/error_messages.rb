module NxtSchema
  class ErrorMessages
    class << self
      def values
        @values ||= {}
      end

      def values=(value)
        @values = value
      end

      def load(paths = files)
        Array(paths).each do |path|
          new_values = YAML.load(ERB.new(File.read(path)).result).with_indifferent_access
          self.values = values.deep_merge!(new_values)
        end
      end

      def resolve(locale, key, **options)
        message = begin
          values.fetch(locale).fetch(key)
        rescue KeyError
          raise "Could not resolve error message for #{locale}->#{key}"
        end

        message % options
      end

      def files
        @files ||= begin
          files = Dir.entries(File.expand_path('../error_messages/', __FILE__)).map do |filename|
            File.expand_path("../error_messages/#{filename}", __FILE__)
          end

          files.select { |f| !File.directory? f }
        end
      end
    end
  end
end
