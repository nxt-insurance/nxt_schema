module NxtSchema
  module Node
    class Array < Node::Base
      def initialize(name, parent_node, options, &block)
        @store = []
        @value_store = []

        super(name, ::Array, parent_node, options, &block)
      end

      delegate_missing_to :value_store

      def apply(target)
        if target.respond_to?(:each)
          target.each_with_index do |item, index|
            if store.any? { |node| node.apply(item) }
              value_store << item

              validations.each do |validation|
                validation_args = [target, self]
                validation.call(*validation_args.take(validation.arity))
              end
            else
              add_error(index, "Did not match any node in #{store}")
            end
          end
        else
          add_error(item, "#{target} does not respond to :each")
        end

        self
      end
    end
  end
end
