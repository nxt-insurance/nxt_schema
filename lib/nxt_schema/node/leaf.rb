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

      def apply(value, parent_errors = {}, parent_value_store = {}, index_or_name = name)
        self.node_errors = parent_errors[name] ||= { node_errors_key => [] }
        value = type[value]

        validations.each do |validation|
          validation_args = [value, self]
          validation.call(*validation_args.take(validation.arity))
        end

        parent_value_store[index_or_name] = value

      rescue NxtSchema::Errors::CoercionError => error
        add_error(error.message)
      rescue StandardError => e
        raise e
      ensure
        node_errors.reject! { |_,v| v.empty? }
        return self
      end

      def add_error(error)
        node_errors[node_errors_key] << error

        # error_namespace = [namespace, index_key].compact.join('.')
        # errors[error_namespace] ||= []
        # errors[error_namespace] << error
      end

      def valid?
        node_errors.empty?
      end

      private
    end
  end
end
