module NxtSchema
  module Node
    class Base
      def initialize(name: name_from_index, type:, parent_node:, **options, &block)
        @name = name
        @parent_node = parent_node
        @options = options
        @default_type_system = resolve_default_type_system
        @type = type
        @schema_errors_key = options.fetch(:schema_errors_key, :itself)
        @validations = []
        @level = parent_node ? parent_node.level + 1 : 0
        @all_nodes = parent_node ? (parent_node.all_nodes || []) : []
        @root = parent_node.nil?
        @root_node = parent_node.nil? ? self : parent_node.root_node
        @errors = {}

        # Note that it is not possible to use present? on an instance of NxtSchema::Schema since it inherits from Hash
        evaluate_block(block) if block_given?
      end

      attr_accessor :name,
                    :parent_node,
                    :options,
                    :type,
                    :schema_errors,
                    :namespace,
                    :errors,
                    :validations,
                    :schema_errors_key,
                    :level,
                    :validation_errors,
                    :all_nodes,
                    :value,
                    :default_type_system,
                    :root_node

      def parent(level = 1)
        level.times.inject(self) { |acc| acc.parent_node }
      end

      alias_method :up, :parent

      def default(default_value, &block)
        options.merge!(default: default_value)
        evaluate_block(block) if block_given?
        self
      end

      def maybe(maybe_value, &block)
        options.merge!(maybe: maybe_value)
        evaluate_block(block) if block_given?
        self
      end

      def optional(optional_value, &block)
        options.merge!(optional: optional_value)
        evaluate_block(block) if block_given?
        self
      end

      def validate(key, *args, &block)
        validator = validator(key, *args)
        add_validators(validator)
        evaluate_block(block) if block_given?
        self
      end

      # TODO: Make private what should be private
      def add_schema_error(error, index = schema_errors_key)
        schema_errors[index] ||= []
        schema_errors[index] << error

        validation_errors[index] ||= []
        validation_errors[index] << error
      end

      def add_error(error, index = schema_errors_key)
        validation_errors[index] ||= []
        validation_errors[index] << error
      end

      def validate_all_nodes
        sorted_nodes = all_nodes.sort do |node, other_node|
          [node.level, (!node.leaf?).to_s] <=> [other_node.level, (!other_node.leaf?).to_s]
        end

        # we have to start from the bottom, leafs before others on the same level
        sorted_nodes.reverse_each(&:apply_validations)
      end

      def register_node
        return if in?(all_nodes)

        all_nodes << self
      end

      def apply_validations
        # We don't run validations in case there are schema errors
        # to avoid weird errors
        # First reject empty schema_errors
        schema_errors.reject! { |_, v| v.empty? }

        # TODO: Is this correct? - Do not apply validations when maybe criteria applies?
        unless schema_errors[schema_errors_key]&.any? && !maybe_criteria_applies?
          build_validations

          validations.each do |validation|
            args = [self, value]
            validation.call(*args.take(validation.arity))
          end
        end

        if self.is_a?(NxtSchema::Node::Collection) && value.respond_to?(:each)
          value.each_with_index do |item, index|
            validation_errors[index]&.reject! { |_, v| v.empty? }
          end
        end

        validation_errors.reject! { |_, v| v.empty? }

        self
      end

      def build_validations
        validations_from_options = Array(options.fetch(:validate, []))
        self.validations = validations_from_options
      end

      def schema_errors?
        schema_errors.reject! { |_, v| v.empty? }
        schema_errors.any?
      end

      def validation_errors?
        validation_errors.reject! { |_, v| v.empty? }
        validation_errors.any?
      end

      def optional?
        optional_evaluator = options[:optional]

        if optional_evaluator.respond_to?(:call)
          add_validators(OptionalNodeValidator.new(optional_evaluator))
        else
          optional_evaluator
        end
      end

      def root?
        @root
      end

      def leaf?
        false
      end

      def valid?
        # TODO: We should probably check if we applied and validation errors ran.
        validation_errors.empty?
      end

      def add_validators(validator)
        options[:validate] ||= []
        options[:validate] = Array(options.fetch(:validate, []))
        options[:validate] << validator
      end

      def validator(key, *args)
        Validations::Registry::VALIDATORS.resolve(key).call(*args)
      end

      def validate_with(&block)
        add_validators(
          ->(node) { NxtSchema::Validations::Proxy.new(node).validate(&block) }
        )
      end

      private

      def maybe_criteria_applies?
        @maybe_criteria_applies ||= begin
          options.key?(:maybe) && MaybeEvaluator.new(options.fetch(:maybe), value).call
        end
      end

      def self_without_empty_schema_errors
        schema_errors.reject! { |_, v| v.empty? }
        validate_all_nodes if root?
        self.errors = flat_validation_errors(validation_errors, name)
        self
      end

      def raise_coercion_error(value, type)
        raise Dry::Types::ConstraintError.new(value, type)
      end

      def flat_validation_errors(hash, namespace, acc = {})
        hash.each_with_object(acc) do |(key, val), acc|
          current_namespace = [namespace, key].reject { |namespace| namespace == schema_errors_key }.compact.join('.')

          if val.is_a?(::Hash)
            flat_validation_errors(val, current_namespace, acc)
          else
            acc[current_namespace] ||= []
            acc[current_namespace] += Array(val)
          end
        end
      end

      def name_from_index
        if parent_node
          if parent_node.is_a?(NxtSchema::Node::Array)
            size + 1
          else
            raise ArgumentError, "Nodes with parent_node: #{parent_node} cannot be anonymous"
          end
        else
          :root
        end
      end

      def evaluate_block(block)
        if block.arity.zero?
          instance_exec(&block)
        else
          block.call(self)
        end
      end

      def resolve_default_type_system
        options.fetch(:default_type_system) do
          parent_node && parent_node.options[:default_type_system] || NxtSchema::Types::Strict
        end
      end
    end
  end
end
