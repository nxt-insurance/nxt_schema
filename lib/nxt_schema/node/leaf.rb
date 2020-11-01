module NxtSchema
  module Node
    class Leaf < Node::Base
      def initialize(name:, type: :String, parent_node:, **options, &block)
        super
      end

      def leaf?
        true
      end
    end
  end
end
