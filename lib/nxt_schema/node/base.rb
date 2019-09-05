module NxtSchema
  module Node
    class Base
      def initialize(name, type, parent_node, **options, &block)
        @name = name
        @parent_node = parent_node
        @options = options
        @type = type
        @validations = Array(options.fetch(:validate, []))
        initialize_error_stores
        # Note that it is not possible to use present? on an instance of NxtSchema::Schema since it inherits from Hash
        block.call(self) if block_given?
      end

      attr_accessor :name, :parent_node, :options, :type, :node_errors, :namespace, :errors, :validations

      def add_error(error, index_key = nil)
        error_namespace = [namespace, index_key].compact.join('.')
        errors[error_namespace] ||= []
        errors[error_namespace] << error
      end

      def valid?
        errors.reject! { |_, v| v.empty? }
        errors.empty?
      end

      private

      def resolve_namespace
        return unless [parent_node&.namespace, name].compact.any?
        [parent_node&.namespace, name].compact.join('.')
      end

      def resolve_type(name)
        Type::Registry.instance.resolve(name)
      end

      def raise_coercion_error(value, type)
        raise NxtSchema::Errors::CoercionError.new(value, type)
      end
    end
  end
end
