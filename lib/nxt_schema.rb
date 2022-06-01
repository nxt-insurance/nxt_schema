require 'nxt_schema/version'
require 'active_support/all'
require 'dry-types'
require 'nxt_registry'
require 'nxt_init'
require 'yaml'

require_relative 'nxt_schema/types'
require_relative 'nxt_schema/callable'
require_relative 'nxt_schema/node'
require_relative 'nxt_schema/undefined'
require_relative 'nxt_schema/error'
require_relative 'nxt_schema/errors/invalid'
require_relative 'nxt_schema/errors/invalid_options'
require_relative 'nxt_schema/errors/coercion_error'

require_relative 'nxt_schema/validators/registry'
require_relative 'nxt_schema/validators/validate_with_proxy'
require_relative 'nxt_schema/validators/error_messages'
require_relative 'nxt_schema/validators/validator'
require_relative 'nxt_schema/validators/attribute'
require_relative 'nxt_schema/validators/equal_to'
require_relative 'nxt_schema/validators/conditionally_required_node'
require_relative 'nxt_schema/validators/optional_node'
require_relative 'nxt_schema/validators/greater_than'
require_relative 'nxt_schema/validators/greater_than_or_equal'
require_relative 'nxt_schema/validators/less_than'
require_relative 'nxt_schema/validators/less_than_or_equal'
require_relative 'nxt_schema/validators/pattern'
require_relative 'nxt_schema/validators/included_in'
require_relative 'nxt_schema/validators/includes'
require_relative 'nxt_schema/validators/excluded_in'
require_relative 'nxt_schema/validators/excludes'
require_relative 'nxt_schema/validators/query'

require_relative 'nxt_schema/template/on_evaluator'
require_relative 'nxt_schema/template/maybe_evaluator'
require_relative 'nxt_schema/template/type_resolver'
require_relative 'nxt_schema/template/type_system_resolver'
require_relative 'nxt_schema/template/base'
require_relative 'nxt_schema/template/sub_nodes'
require_relative 'nxt_schema/template/has_sub_nodes'
require_relative 'nxt_schema/template/any_of'
require_relative 'nxt_schema/template/collection'
require_relative 'nxt_schema/template/schema'
require_relative 'nxt_schema/template/leaf'

require_relative 'nxt_schema/node/errors/schema_error'
require_relative 'nxt_schema/node/errors/validation_error'
require_relative 'nxt_schema/node/error_store'
require_relative 'nxt_schema/node/base'
require_relative 'nxt_schema/node/any_of'
require_relative 'nxt_schema/node/leaf'
require_relative 'nxt_schema/node/collection'
require_relative 'nxt_schema/node/schema'
require_relative 'nxt_schema/dsl'
require_relative 'nxt_schema/registry/proxy'
require_relative 'nxt_schema/registry'

module NxtSchema
  extend Dsl

  def register_error_messages(*paths)
    Validators::ErrorMessages.load(paths)
  end

  def register_validator(validator, *keys)
    keys.each { |key| NxtSchema::Validators::REGISTRY.register(key, validator) }
  end

  def register_type(key, type)
    NxtSchema::Types.registry(:types).register(key, type)
  end

  # Load default messages
  Validators::ErrorMessages.load

  module_function :register_error_messages, :register_validator, :register_type
end
