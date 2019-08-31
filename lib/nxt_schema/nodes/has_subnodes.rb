require_relative 'hash_node'
require_relative 'array_node'
require_relative 'simple_node'

module NxtSchema
  module Nodes
    module HasSubNodes
      attr_accessor :store, :value_store

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

      def required(name, options, &block)
        node(name, options.merge(optional: false), &block)
      end

      def optional(name, options, &block)
        node(name, options.merge(optional: true), &block)
      end

      def nodes(name, options, &block)
        node(name, options.merge(type: Array), &block)
      end
    end
  end
end

NxtSchema::Nodes::HashNode.include(::NxtSchema::Nodes::HasSubNodes)
NxtSchema::Nodes::ArrayNode.include(::NxtSchema::Nodes::HasSubNodes)
