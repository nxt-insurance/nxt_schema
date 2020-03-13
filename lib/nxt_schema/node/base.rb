module NxtSchema
  module Node
    class Base
      def initialize(name: name_from_index, type:, parent_node:, **options, &block)
        @name = name
        @parent_node = parent_node
        @options = options
        @type_system = resolve_type_system
        @additional_keys_strategy = resolve_additional_keys_strategy
        @type = type
        @schema_errors_key = options.fetch(:schema_errors_key, :itself)
        @validations = []
        @level = parent_node ? parent_node.level + 1 : 0
        @all_nodes = parent_node ? (parent_node.all_nodes || {}) : {}
        @is_root = parent_node.nil?
        @root = parent_node.nil? ? self : parent_node.root
        @errors = {}
        @context = nil
        @applied = false
        @input = nil
        @value = NxtSchema::Undefined.new
        @language = :en

        # Note that it is not possible to use present? on an instance of NxtSchema::Schema since it inherits from Hash
        evaluate_block(block) if block_given?
      end

      attr_accessor :name,
                    :parent_node,
                    :options,
                    :type,
                    :schema_errors,
                    :errors,
                    :validations,
                    :schema_errors_key,
                    :level,
                    :validation_errors,
                    :all_nodes,
                    :value,
                    :type_system,
                    :root,
                    :context,
                    :applied,
                    :input,
                    :additional_keys_strategy,
                    :language

      alias_method :types, :type_system

      def parent(level = 1)
        level.times.inject(self) { |acc| acc.parent_node }
      end

      alias_method :up, :parent

      def default(default_value, &block)
        options.merge!(default: default_value)
        evaluate_block(block) if block_given?
        self
      end

      def value_or_default_value(value)
        if !value && options.key?(:default)
          DefaultValueEvaluator.new(self, options.fetch(:default)).call
        else
          value
        end
      end

      def maybe(maybe_value, &block)
        options.merge!(maybe: maybe_value)
        evaluate_block(block) if block_given?
        self
      end

      def optional(optional_value, &block)
        raise ArgumentError, 'Optional nodes can only exist within schemas' unless parent.is_a?(NxtSchema::Node::Schema)

        options.merge!(optional: optional_value)
        evaluate_block(block) if block_given?
        self
      end

      def presence(presence_value, &block)
        raise ArgumentError, 'Present nodes can only exist within schemas' unless parent.is_a?(NxtSchema::Node::Schema)

        options.merge!(presence: presence_value)
        evaluate_block(block) if block_given?
        self
      end

      def presence?
        @presence ||= begin
          presence_option = options[:presence]

          options[:presence] = if presence_option.respond_to?(:call)
            Callable.new(presence_option).call(self, value)
          else
            presence_option
          end
        end
      end

      def validate(key, *args, &block)
        if key.is_a?(Symbol)
          validator = validator(key, *args)
        elsif key.respond_to?(:call)
          validator = key
        else
          raise ArgumentError, "Don't know how to resolve validator from: #{key}"
        end

        add_validators(validator)
        evaluate_block(block) if block_given?
        self
      end

      def add_error(error, index = schema_errors_key)
        validation_errors[index] ||= []
        validation_errors[index] << error
      end

      def validate_all_nodes
        sorted_nodes = all_nodes.values.sort do |node, other_node|
          [node.level, (!node.leaf?).to_s] <=> [other_node.level, (!other_node.leaf?).to_s]
        end

        # we have to start from the bottom, leafs before others on the same level
        sorted_nodes.reverse_each(&:apply_validations)
      end

      def apply_validations
        # We don't run validations in case there are schema errors
        # to avoid weird errors
        # First reject empty schema_errors
        schema_errors.reject! { |_, v| v.empty? }

        # TODO: Is this correct? - Do not apply validations when maybe criteria applies?
        unless schema_errors[schema_errors_key]&.any? && !maybe_criteria_applies?(value)
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

      def root?
        @is_root
      end

      def leaf?
        false
      end

      def valid?
        raise SchemaNotAppliedError, 'Schema was not applied yet' unless applied?

        validation_errors.empty?
      end

      def add_validators(validator)
        options[:validate] ||= []
        options[:validate] = Array(options.fetch(:validate, []))
        options[:validate] << validator
      end

      def validator(key, *args)
        Validators::Registry::VALIDATORS.resolve(key).new(*args, language: language).build
      end

      def validate_with(&block)
        add_validators(
          ->(node) { NxtSchema::Node::ValidateWithProxy.new(node).validate(&block) }
        )
      end

      private

      def register_node(context)
        return if all_nodes.key?(object_id)

        self.context = context
        all_nodes[object_id] = self
      end

      def applied?
        @applied
      end

      def mark_as_applied
        self.applied = true
      end

      def add_schema_error(error, index = schema_errors_key)
        schema_errors[index] ||= []
        schema_errors[index] << error

        add_error(error, index)
      end

      def maybe_criteria_applies?(value)
        @maybe_criteria_applies ||= begin
          options.key?(:maybe) && MaybeEvaluator.new(self, options.fetch(:maybe), value).call
        end
      end

      def self_without_empty_schema_errors
        schema_errors.reject! { |_, v| v.empty? }
        validate_all_nodes if root?
        self.errors = flat_validation_errors(validation_errors, name)
        self
      end

      def flat_validation_errors(errors, namespace, acc = {})
        errors.each_with_object(acc) do |(key, val), acc|
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
          if parent_node.is_a?(NxtSchema::Node::Collection)
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
          evaluator_args = [self, value]
          block.call(*evaluator_args.take(block.arity))
        end
      end

      def resolve_type_system
        type_system = options.fetch(:type_system) { parent_node&.type_system }

        self.type_system = if type_system.is_a?(Module)
          type_system
        elsif type_system.is_a?(Symbol) || type_system.is_a?(String)
          "NxtSchema::Types::#{type_system.to_s.classify}".constantize
        else
          NxtSchema::Types
        end
      end

      def resolve_additional_keys_strategy
        options.fetch(:additional_keys) { parent_node&.send(:resolve_additional_keys_strategy) || :ignore }
      end

      def type_resolver
        @type_resolver ||= begin
          if root?
            TypeResolver.new
          else
            raise NoMethodError, 'type_resolver is only available on root node'
          end
        end
      end

      def coerce_value(value)
        type[value]
      end
    end
  end
end
