require 'singleton'

module NxtSchema
  module Type
    class Registry
      include Singleton

      def initialize
        @store = ActiveSupport::HashWithIndifferentAccess.new
      end

      def register_type(name, &block)
        raise ArgumentError, "Type #{name} already registered" if store.key?(name)
        store[name] = Type::Base.new(name, block)
      end

      def resolve(name)
        store.fetch(name) { raise ArgumentError, "No type #{name} registered" }
      end

      private

      attr_accessor :store
    end
  end
end
