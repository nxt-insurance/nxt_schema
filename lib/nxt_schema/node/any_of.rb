module NxtSchema
  module Node
    class AnyOf
      def initialize(parent_node:, **options, &block)
        @parent_node = parent_node
        @options = options
        @level = parent_node ? parent_node.level + 1 : 0
        @is_root = parent_node.nil?
        @root = parent_node.nil? ? self : parent_node.root
      end

      attr_accessor :name, :parent_node, :options, :level, :root

      def apply(input = MissingInput, context = nil, parent = nil)
        application_class.new(node: self, input: input, parent: parent, context: context).call
      end
    end
  end
end
