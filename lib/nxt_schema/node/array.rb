module NxtSchema
  module Node
    class Array < Node::Base
      include HasSubNodes

      DEFAULT_TYPE = NxtSchema::Types::Strict::Array

      def initialize(name:, value_type: DEFAULT_TYPE, parent_node:, **options, &block)
        super
      end
    end
  end
end
