module NxtSchema
  module Node
    class ArrayNode < Node::Base
      def initialize(name, parent_node, options, &block)
        @store = []
        @value_store = []

        super(name, Array, parent_node, options, &block)
      end

      delegate_missing_to :value_store

      def validate(target)
        target.each do |item|
          if store.any? { |node| node.validate(item) }
            value_store << item

            validations.each do |validation|
              validation_args = [target, self]
              validation.call(*validation_args.take(validation.arity))
            end
          else
            add_error(item, "Did not match any node in #{store}")
          end
        end

        self
      end
    end
  end
end
