module NxtSchema
  module Node
    class Base
      def initialize(name, type, parent_node, **options, &block)
        @name = name
        @parent_node = parent_node
        @options = options
        @type = type
        @validations = Array(options.fetch(:validate, []))
        # Note that it is not possible to use present? on an instance of NxtSchema::Schema since it inherits from Hash
        @node_errors = parent_node.nil? ? {} : (parent_node.node_errors[name] ||= {})
        @namespace = resolve_namespace
        @errors = parent_node.nil? ? {} : parent_node.errors

        block.call(self) if block_given?
      end

      attr_accessor :name, :parent_node, :options, :type, :node_errors, :namespace, :errors, :validations

      def add_error(value, error)
        node_errors[value] ||= []
        node_errors[value] ||= error

        errors[namespace] ||= []
        errors[namespace] << { value => NxtSchema::Node::Error.new(namespace, value, error) }
      end

      private

      def resolve_namespace
        return unless [parent_node&.namespace, name].compact.any?
        [parent_node&.namespace, name].compact.join('.')
      end
    end
  end
end
