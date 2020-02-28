module NxtSchema
  module Node
    class Constructor < Node::Schema
      def initialize(name:, type: NxtSchema::Types::Constructor(::OpenStruct), parent_node:, **options, &block)
        super
      end
    end
  end
end
