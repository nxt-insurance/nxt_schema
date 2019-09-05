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

      def apply(value)
        array = type[value]

        if array_violates_emptiness?(array)
          add_error("Array is not allowed to be empty")
        else
          array.each_with_index do |item, index|
            if store.any? { |node| node.apply(item).valid? }
              value_store << item

              validations.each do |validation|
                validation_args = [array, self]
                validation.call(*validation_args.take(validation.arity))
              end
            end
          end
        end


      rescue NxtSchema::Errors::CoercionError => error
        add_error(error.message)
      ensure
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
