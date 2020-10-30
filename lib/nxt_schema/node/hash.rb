module NxtSchema
  module Node
    class Hash < Node::Base
      include HasSubNodes

      def initialize(name:, value_type: :Hash, parent_node:, **options, &block)
        super
      end
    end
  end
end
