module NxtSchema
  module Node
    class Leaf < Node::Base
      def initialize(name, type, parent_node, **options, &block)
        super
        @type = resolve_type(type)
      end

      def leaf?
        true
      end

      def apply(value)
        value = type[value]

        validations.each do |validation|
          validation_args = [value, self]
          validation.call(*validation_args.take(validation.arity))
        end

      rescue NxtSchema::Errors::CoercionError => error
        add_error(error.message)
      ensure
        return self
      end

      private

      def initialize_error_stores
        # @node_errors = parent_node.node_errors[name] ||= []
        @namespace = resolve_namespace
        @errors = parent_node.errors
      end
    end
  end
end
