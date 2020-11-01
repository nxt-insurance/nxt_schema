module NxtSchema
  module Node
    class Collection < Node::Base
      include HasSubNodes

      DEFAULT_TYPE = NxtSchema::Types::Strict::Array

      def initialize(name:, type: DEFAULT_TYPE, parent_node:, **options, &block)
        super
      end
    end
  end
end
