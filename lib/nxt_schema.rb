require 'nxt_schema/version'
require 'active_support/all'
require 'dry-types'
require 'nxt_registry'
require 'nxt_init'
require 'yaml'

require_relative 'nxt_schema/types'
require_relative 'nxt_schema/callable'
require_relative 'nxt_schema/application'
require_relative 'nxt_schema/missing_input'
require_relative 'nxt_schema/errors/invalid_options'

require_relative 'nxt_schema/validators/registry'
require_relative 'nxt_schema/validators/error_messages'
require_relative 'nxt_schema/validators/validator'
require_relative 'nxt_schema/validators/attribute'
require_relative 'nxt_schema/validators/equal_to'
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

require_relative 'nxt_schema/node/on_evaluator'
require_relative 'nxt_schema/node/maybe_evaluator'
require_relative 'nxt_schema/node/type_resolver'
require_relative 'nxt_schema/node/type_system_resolver'
require_relative 'nxt_schema/node/base'
require_relative 'nxt_schema/node/sub_nodes'
require_relative 'nxt_schema/node/has_sub_nodes'
require_relative 'nxt_schema/node/any_of'
require_relative 'nxt_schema/node/collection'
require_relative 'nxt_schema/node/schema'
require_relative 'nxt_schema/node/leaf'

require_relative 'nxt_schema/application/errors/schema_error'
require_relative 'nxt_schema/application/errors/validation_error'
require_relative 'nxt_schema/application/error_store'
require_relative 'nxt_schema/application/base'
require_relative 'nxt_schema/application/any_of'
require_relative 'nxt_schema/application/leaf'
require_relative 'nxt_schema/application/collection'
require_relative 'nxt_schema/application/schema'
require_relative 'nxt_schema/dsl'

module NxtSchema
  extend Dsl

  # TODO: Should probably be part of dsl
  def register_error_messages(*paths)
    Validators::ErrorMessages.load(paths)
  end

  # Load default messages
  Validators::ErrorMessages.load

  module_function :register_error_messages
end
