module NxtSchema
  class Node
    def initialize(name, parent_node, options, &block)
      @name = name
      @parent_node = parent_node
      @options = options
      @type = options.fetch(:type)
      # Note that it is not possible to use present? on an instance of NxtSchema::Schema since it inherits from Hash
      @errors = parent_node.nil? ? {} : (parent_node.errors[name] ||= {})
      @namespace = resolve_namespace
      @flat_errors = parent_node.nil? ? {} : parent_node.flat_errors

      block.call(self) if block_given?
    end

    attr_accessor :name, :parent_node, :options, :type, :errors, :namespace, :flat_errors

    private

    def resolve_namespace
      [parent_node&.namespace, name].compact.join('.')
    end

    def add_flat_error(value, error)
      flat_errors[namespace] ||= []
      flat_errors[namespace] << { value => NxtSchema::Nodes::Error.new(namespace, value, error) }
    end
  end
end
