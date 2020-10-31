module NxtSchema
  module Node
    class Hash < Node::Base
      include HasSubNodes

      DEFAULT_TYPE = NxtSchema::Types::Strict::Hash

      def initialize(name:, value_type: DEFAULT_TYPE, parent_node:, **options, &block)
        super
      end
    end
  end
end
