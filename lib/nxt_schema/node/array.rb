module NxtSchema
  module Node
    class Array < Node::Base
      include NxtSchema::Node::Collection

      def initialize(name, parent_node, options, &block)
        @store = []
        @value_store = []

        super(name, NxtSchema::Type::Strict::Array, parent_node, options, &block)
      end

      delegate_missing_to :value_store

        def apply(value, parent_errors = {})
          self.node_errors = parent_errors[name] ||= { node_errors_key => [] }
        array = type[value]

        if array_violates_emptiness?(array)
          node_errors[node_errors_key] << "Array is not allowed to be empty"
        else
          array.each_with_index do |item, index|
            item_errors = node_errors[index] ||= { node_errors_key => [] }
            # node_errors should be a hash on each node (as it used to be)
            if store.any? { |node| node.apply(item, item_errors).valid? }
              value_store << item
            end

            item_errors.reject! { |_,v| v.empty? }
          end

          validations.each do |validation|
            validation_args = [array, self]
            validation.call(*validation_args.take(validation.arity))
          end
        end

      rescue NxtSchema::Errors::CoercionError => error
        node_errors[node_errors_key] << error.message
      rescue StandardError => e
          raise e
      ensure
        node_errors.reject! { |_,v| v.empty? }
        return self
      end

      private

      def array_violates_emptiness?(array)
        return unless array.empty?
        # maybe
        true
      end

      def accumulate_node_errors
        store.each_with_object(node_errors) do |node, acc|
          acc[node.name] ||= {}
          acc[node.name] = acc[node.name].merge(node.node_errors)
        end
      end
    end
  end
end
