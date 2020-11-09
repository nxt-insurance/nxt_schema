require "nxt_schema/version"
require "active_support/all"
require 'dry-types'
require 'nxt_registry'
require 'nxt_init'
require 'yaml'

require_relative 'nxt_schema/types'
require_relative 'nxt_schema/callable'
require_relative 'nxt_schema/application'
require_relative 'nxt_schema/missing_input'
require_relative 'nxt_schema/errors/invalid_options'

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

require_relative 'nxt_schema/application/errors'
require_relative 'nxt_schema/application/base'
require_relative 'nxt_schema/application/any_of'
require_relative 'nxt_schema/application/leaf'
require_relative 'nxt_schema/application/collection'
require_relative 'nxt_schema/application/schema'
require_relative 'nxt_schema/dsl'

module NxtSchema
  extend Dsl
end
