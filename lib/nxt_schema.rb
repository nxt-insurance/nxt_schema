require "nxt_schema/version"
require "pry"
require "active_support/all"
require 'dry-types'
require 'nxt_registry'
require 'yaml'

require "nxt_schema/types"
require "nxt_schema/undefined"
require "nxt_schema/registry"
require "nxt_schema/callable"
require "nxt_schema/callable_or_value"
require "nxt_schema/validators/registry"
require "nxt_schema/node/validate_with_proxy"

require "nxt_schema/errors"
require "nxt_schema/errors/error"
require "nxt_schema/errors/schema_not_applied_error"
require "nxt_schema/errors/invalid_options_error"

require "nxt_schema/error_messages"
require "nxt_schema/validators/validator"
require "nxt_schema/validators/attribute"
require "nxt_schema/validators/equality"
require "nxt_schema/validators/optional_node"
require "nxt_schema/validators/greater_than"
require "nxt_schema/validators/greater_than_or_equal"
require "nxt_schema/validators/less_than"
require "nxt_schema/validators/less_than_or_equal"
require "nxt_schema/validators/pattern"
require "nxt_schema/validators/included"
require "nxt_schema/validators/includes"
require "nxt_schema/validators/excluded"
require "nxt_schema/validators/excludes"
require "nxt_schema/validators/query"

require "nxt_schema/node"
require "nxt_schema/node/type_resolver"
require "nxt_schema/node/maybe_evaluator"
require "nxt_schema/node/default_value_evaluator"
require "nxt_schema/node/base"
require "nxt_schema/node/error"
require "nxt_schema/node/has_subnodes"
require "nxt_schema/node/template_store"
require "nxt_schema/node/schema"
require "nxt_schema/node/collection"
require "nxt_schema/node/leaf"
require "nxt_schema/dsl"

module NxtSchema
  def register_validator(validator, *keys)
    keys.each do |key|
      NxtSchema::Validators::Registry::VALIDATORS.register(key, validator)
    end
  end

  def register_type(key, type)
    NxtSchema::Types.const_set(key.to_s, type)
  end

  def register_error_messages(*paths)
    ErrorMessages.load(paths)
  end

  # Load default messages
  ErrorMessages.load

  module_function :register_validator, :register_type, :register_error_messages
end
