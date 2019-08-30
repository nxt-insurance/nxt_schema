module NxtSchema
  module Nodes
    class SimpleNode
      def initialize(name, parent_node, options)
        @name = name
        @parent_node = parent_node
        @options = options
        @type = options.fetch(:type)
      end

      attr_accessor :name, :parent_node, :options, :type
    end
  end
end
