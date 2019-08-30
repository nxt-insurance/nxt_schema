module NxtSchema
  class Node
    def initialize(name, parent_node, options, &block)
      @name = name
      @parent_node = parent_node
      @options = options
      @type = options.fetch(:type)

      block.call(self) if block_given?
    end

    attr_accessor :name, :parent_node, :options, :type
  end
end
