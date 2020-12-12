module NxtSchema
  module Params
    class Proxy
      def initialize(namespace)
        @registry = ::NxtRegistry::Registry.new(namespace, call: false)
      end

      attr_reader :registry

      delegate_missing_to :registry

      def apply(key, input)
        resolve!(key).apply(input: input)
      end

      def apply!(key, input)
        resolve!(key).apply!(input: input)
      end
    end
  end
end
