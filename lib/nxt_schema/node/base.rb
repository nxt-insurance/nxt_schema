module NxtSchema
  module Node
    class Base
      def initialize(name, type, parent_node, **options, &block)
        @name = name
        @parent_node = parent_node
        @options = options
        @type = type
        @node_errors_key = options.fetch(:node_errors_key, :itself)
        @validations = Array(options.fetch(:validate, []))

        # Note that it is not possible to use present? on an instance of NxtSchema::Schema since it inherits from Hash
        block.call(self) if block_given?
      end

      attr_accessor :name, :parent_node, :options, :type, :node_errors, :namespace, :errors, :validations, :node_errors_key

      def add_error(error, index = node_errors_key)
        node_errors[index] ||= []
        node_errors[index] << error

        # error_namespace = [namespace, index_key].compact.join('.')
        # errors[error_namespace] ||= []
        # errors[error_namespace] << error
      end

      def errors_on_self
        node_errors.errors_on_self
      end

      def valid?
        node_errors.reject! { |_, v| v.empty? }
        node_errors.empty?
      end

      private

      def maybe_criteria_applies?(value)
        return unless options.key?(:maybe)
        MaybeEvaluator.new(options.fetch(:maybe), value).call
      end

      def self_without_empty_node_errors
        node_errors.reject! { |_, v| v.empty? }
        self
      end

      def raise_coercion_error(value, type)
        raise NxtSchema::Errors::CoercionError.new(value, type)
      end
    end
  end
end
