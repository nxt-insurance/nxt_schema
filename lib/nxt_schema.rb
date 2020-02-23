require "nxt_schema/version"
require "pry"
require "active_support/all"
require 'dry-types'
require 'nxt_registry'

require "nxt_schema/types"
require "nxt_schema/registry"
require "nxt_schema/validations/registry"
require "nxt_schema/validations/proxy"
require "nxt_schema/validations/validators/optional_node"

require "nxt_schema/errors"
require "nxt_schema/errors/error"
require "nxt_schema/errors/required_key_missing_error"
require "nxt_schema/errors/coercion_error"



require "nxt_schema/node"
require "nxt_schema/node/maybe_evaluator"
require "nxt_schema/node/optional_node_validator"
require "nxt_schema/node/base"
require "nxt_schema/node/error"
require "nxt_schema/node/has_subnodes"
require "nxt_schema/node/template_store"
require "nxt_schema/node/schema"
require "nxt_schema/node/open_struct"
require "nxt_schema/node/collection"
require "nxt_schema/node/leaf"
require "nxt_schema/dsl"

module NxtSchema

end
