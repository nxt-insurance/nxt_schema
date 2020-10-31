require "nxt_schema/version"
require "active_support/all"
require 'dry-types'
require 'nxt_registry'
require 'yaml'
require_relative 'nxt_schema/types'
require_relative 'nxt_schema/application'

require_relative 'nxt_schema/node/type_resolver'
require_relative 'nxt_schema/node/base'
require_relative 'nxt_schema/node/sub_nodes'
require_relative 'nxt_schema/node/has_sub_nodes'
require_relative 'nxt_schema/node/array'
require_relative 'nxt_schema/node/hash'
require_relative 'nxt_schema/node/leaf'

require_relative 'nxt_schema/application/base'
require_relative 'nxt_schema/application/leaf'
require_relative 'nxt_schema/application/array'
require_relative 'nxt_schema/application/hash'
require_relative 'nxt_schema/dsl'

module NxtSchema
  extend Dsl
end
