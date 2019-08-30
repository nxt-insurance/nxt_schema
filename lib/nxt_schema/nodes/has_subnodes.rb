require_relative 'hash_node'
require_relative 'array_node'
require_relative 'simple_node'

module NxtSchema
  module Nodes
    module HasSubNodes
      attr_accessor :store

      def node(name, options, &block)
        child_node = case options.fetch(:type).to_s
        when 'Hash'
          NxtSchema::Nodes::HashNode.new(name, self, **options, &block)
        when 'Array'
          NxtSchema::Nodes::ArrayNode.new(name, self, **options, &block)
        else
          NxtSchema::Nodes::SimpleNode.new(name, self, **options)
        end

        store.push(child_node)
      end

      def nodes(name, options, &block)
        node(name, options.merge(type: Array), &block)
      end
    end
  end
end

NxtSchema::Nodes::HashNode.include(::NxtSchema::Nodes::HasSubNodes)
NxtSchema::Nodes::ArrayNode.include(::NxtSchema::Nodes::HasSubNodes)
