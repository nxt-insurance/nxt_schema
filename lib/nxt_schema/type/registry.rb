require 'singleton'

module NxtSchema
  module Type
    class Registry
      include Singleton

      def initialize
        @store = ActiveSupport::HashWithIndifferentAccess.new
      end

      def register(name, type)
        raise ArgumentError, "Type #{name} already registered" if store.key?(name)
        store[name] = type
      end

      def resolve(name)
        store.fetch(name) { raise ArgumentError, "No type #{name} registered" }
      end

      private

      attr_accessor :store
    end
  end
end
