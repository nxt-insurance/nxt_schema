module NxtSchema
  module Node
    class Error
      def initialize(path, value, message)
        @path = path
        @value = value
        @message = message
      end

      attr_reader :path, :value, :message
    end
  end
end
