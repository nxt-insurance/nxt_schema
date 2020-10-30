module NxtSchema
  module Node
    class Array < Node::Base
      include HasSubNodes

      def initialize(name:, value_type: :Array, parent_node:, **options, &block)
        super
      end
    end
  end
end
