module NxtSchema
  module Node
    class Schema < Node::Base
      include HasSubNodes

      DEFAULT_TYPE = NxtSchema::Types::Strict::Hash

      def initialize(name:, type: DEFAULT_TYPE, parent_node:, **options, &block)
        super
      end
    end
  end
end
