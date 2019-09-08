module NxtSchema
  module Node
    class Array < Node::Base
      include NxtSchema::Node::Collection

      def initialize(name, parent_node, options, &block)
        @store = []

        super(name, NxtSchema::Type::Strict::Array, parent_node, options, &block)
      end

      delegate_missing_to :value_store

      def apply(value, parent_errors = {}, parent_value_store = {}, index_or_name = name)
        self.node_errors = parent_errors[name] ||= { node_errors_key => [] }
        self.value_store = parent_value_store[index_or_name] ||= []
        array = type[value]

        if array_violates_emptiness?(array)
          add_error("Array is not allowed to be empty")
        else
          array.each_with_index do |item, index|
            item_errors = node_errors[index] ||= { node_errors_key => [] }

            # When an array provides multiple schemas, and none is valid we only return the errors for
            # a single schema => Would probably be better to merge them somehow!!!
            store.each do |node|
              node.apply(item, { node_errors_key => [] }, value_store, index)
              if node.valid?
                node_errors[index][node.name] = node.node_errors
                break
              else
                # merge errors here instead of assigning
                node_errors[index][node.name] = node.node_errors
              end
            end

            item_errors.reject! { |_, v| v.empty? }
          end

          validations.each do |validation|
            validation_args = [array, self]
            validation.call(*validation_args.take(validation.arity))
          end
        end

      rescue NxtSchema::Errors::CoercionError => error
        add_error(error.message)
      rescue StandardError => e
        raise e
      ensure
        node_errors.reject! { |_, v| v.empty? }
        return self
      end

      private

      def array_violates_emptiness?(array)
        return unless array.empty?
        # maybe
        true
      end
    end
  end
end
