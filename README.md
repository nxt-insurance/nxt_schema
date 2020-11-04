# NxtSchema

## TODO:

- Add back validations
- Make nested schemas work properly (value coercion and error collection)
- Add node presence methods
    - nodes 
        (move methods to has_sub_nodes so it can only be called with name and maybe instance exec to prevent calling it from outside if possible)
        - optional --> optional node (schemas and collections)
            --> schemas
        - omnipresent --> node that is present with nil as default (Only makes sense in schemas!)
            --> Make sure this only is used in schemas!!!
        - required --> node that is not optional
            --> schemas
    - values (move methods to node)
        - maybe
        - default
- How do we want to deal with nil values? 
    --> Probably global option(s) would be nice
    --> Probably should not be ok with nils by default
--> Raise when options are impossible --> optional and present, required and optional, required and present
--> Do not forget to collect Flat errors!
- We do not need any of and all of since this is possible with optional and required keywords

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nxt_schema'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nxt_schema

## Usage

```ruby
# Schema with hash root
schema = NxtSchema.root(:company) do 
  requires(:name, :String)  
  requires(:value, :Integer).maybe(nil)  
  present(:stock_options, :Bool).default(false)
  
  schema(:address) do
    requires(:street, :String)
    requires(:street_number, :Integer)
  end

  # Use nodes to create an array of typed nodes
  # The following simple means an array of strings 
  nodes(:products) do
    node(:product, :String)
  end

    
  nodes(:employees) do
    schema(:employee) do
      POSITIONS = %w[senior junior intern]

      requires(:first_name, :String)
      requires(:last_name, :String)
      optional(:email, :String).validate(:format, /\A.*@.*\z/)
      requires(:position, NxtSchema::Types::Enums[*POSITIONS])
    end
  end
end
  
# Schema with array root
schema = NxtSchema.roots(:companies) do
  schema(:company) do
    requires(:name, :String)  
    requires(:value, :Integer).maybe(nil)
  end
end

schema.apply(your: 'values here')
schema.errors # { 'name.spaced.key': ['all the errors'] }
```

### DSL

Create a new schema with `NxtSchema.root { ... }` or in case you have an array node as root, 
use `NxtSchema.roots { ... }`. Within the schema you can create node simply with the `node(name, type_or_node, **options)` 
method. Each node requires a name and a type and accepts additional options. Node are required per default. 
But you can make them optional by providing the optional option.  

#### Nodes

```ruby
NxtSchema.root do
  node(:first_name, :String)
  node(:last_name, :String, optional: true)
  node(:email, :String, presence: true)
end
```

In order to make the schema more readable you can make use of several predicate aliases to create required, optional or 
(omni)present nodes.  

#### Predicate aliases

```ruby
NxtSchema.root do
  required(:first_name, :String)
  optional(:last_name, :String)
  present(:email, :String)
end
```

### Nodes

The following types of nodes exist

#### Schema Nodes

```ruby
# Create schema nodes with:
required(:test, :Schema) do ... end
schema(:test) do ... end
schema(:test) do ... end
```

#### Collection Nodes

```ruby
# Create collection (array) nodes with:
required(:test, :Collection) do ... end

nodes(:test) do
  # For type checking of array items you can simply add a node with the expected type. 
  # As always you need to give it a name. This would result in an array of string items  
  required(:item, :String) 
end

collection(:test) do ... end
```

#### Leaf Nodes

```ruby
# Create leaf nodes with a basic type 
required(:test, :String) do ... end
```

#### Struct Nodes

```ruby
# Create structs from hash inputs 
struct(:test) do ... end  
```

### Types

The type system is built with dry-types from the amazing https://dry-rb.org/ eco system. Even though dry-types also
offers features such as default values for types as well as maybe types, these features are built directly into 
NxtSchema. Dry.rb also has a gem for schemas and another one dedicated to validations. You should probably
check those out! However, in NxtSchema every node has a type and you can either provide a symbol that will be resolved 
through the type system of the schema. But you can also directly provide an instance of dry type and thus use your 
custom types.    

#### Default type system

You can tell your schema which default type system it should use. Dry-Types comes with a few built in type systems.
Per default NxtSchema will use nominal types if not specified otherwise. If the type cannot be resolved from the default
type system that was specified, NxtSchema will again try to fallback to nominal types. In theory you can provide
a separate type system per node if that's what you want :-D
                               
```ruby
NxtSchema.root do
  required(:test, :String) # The :String will resolve to NxtSchema::Types::Nominal::String
end

NxtSchema.root(type_system: NxtSchema::Types::JSON) do
  required(:test, :Date) # The :Date will resolve to NxtSchema::Types::JSON::Date
  # When the type does not exist in the default type system (there is non JSON::String) we fallback to nominal types
  required(:test, :String) 
end
```

#### NxtSchema.params

NxtSchema.params will give you a schema as root node with NxtSchema::Types::Params as default type system.
This is suitable to validate and coerce your query params. 

```ruby
NxtSchema.params do
  required(:effective_at, :DateTime) # would resolve to Types::Params::DateTime 
  required(:test, :String) # The :String will resolve to NxtSchema::Types::Nominal::String
  required(:advanced, NxtSchema::Types::Params::Bool) # long version of required(:advanced, :Bool)
end
```

#### Custom types

You can also register custom types. In order to check out all the cool things you can do with dry types you should 
check out dry-types on https://dry-rb.org. But here is how you can add a type to the `NxtSchema::Types` module. 

```ruby
NxtSchema.register_type(
  :MyCustomStrippedString,
  NxtSchema::Types::Strict::String.constructor(->(string) { string&.strip })
)

# once registered you can use the type in your schema

NxtSchema.root(:company) do
  required(:name, NxtSchema::Types::MyCustomStrippedString)
end
```

### Values

#### Default values

```ruby
# Define default values as options or with the default method
required(:test, :String).default(value_or_proc)
required(:test, :String, default: value_or_proc) do ... end
```

#### Maybe values 

Allow specific values that are not being coerced

```ruby
# Define maybe values (values that do not match the type)
required(:test, :String).maybe(value_or_proc)
required(:test, :String, maybe: value_or_proc) do ... end
```  

### Validations

NxtSchema comes with a simple validation system and ships with a small set of useful validators. Every node in a schema
implements the `:validate` method. Similar to ActiveModel::Validations it allows you to simply add errors to a node
based on some condition. 

```ruby
  # Simple validation
  required(:test, :String).validate -> (node, value) { node.add_error("#{value} is not valid") if value == 'not allowed' }
  # Built in validations
  required(:test, :String).validate(:attribute, :size, ->(s) { s < 7 }) 
  required(:test, :String).validate(:equality, 'same') 
  required(:test, :String).validate(:excluded, %w[not_allowed]) # excluded in the target: %w[not_allowed]
  required(:test, :String).validate(:included, %w[allowed]) # included in the target: %w[allowed]
  required(:test, :Array).validate(:excludes, 'excluded') # array value itself must exclude 'excluded' 
  required(:test, :Array).validate(:includes, 'included') # array value itself must include 'included'
  required(:test, :Integer).validate(:greater_than, 1) 
  required(:test, :Integer).validate(:greater_than_or_equal, 1) 
  required(:test, :Integer).validate(:less_than, 1) 
  required(:test, :Integer).validate(:less_than_or_equal, 1) 
  required(:test, :String).validate(:pattern, /\A.*@.*\z/) 
  required(:test, :String).validate(:query, :present?) 
```

#### Custom validators

You can also register your custom validators. Therefore you can simply implement a class that returns a lambda on build.
This lambda will be called with the node the validations runs on and it's input value. Except this, you are free in 
how your validator can be used. Check out the specs for some examples. 

```ruby
class MyCustomExclusionValidator
  def initialize(target)
    @target = target
  end

  attr_reader :target

  def build
    lambda do |node, value|
      if target.exclude?(value)
        true
      else
        node.add_error("#{target} should not contain #{value}")
        false # validators must return false in the bad case (add_error already does this as per default)
      end
    end
  end
end

# Register your validators  
NxtSchema.register_validator(MyCustomExclusionValidator, :my_custom_exclusion_validator)

# and then simply reference it with the key you've registered it
schema = NxtSchema.root(:company) do
  requires(:name, :String).validate(:my_custom_exclusion_validator, %w[lemonade])
end

schema.apply(name: 'lemonade').valid? # => false
```

#### Validation messages

- Allow to specify a path to translations
- Add translated errors
- Interpolate with actual vs. expected 

#### Combining validators with custom logic

`node(:test, String).validate(...)` basically adds a validator to the node. Of course you can add multiple validators.
But that means that they will all be executed and errors aggregated. If you want your validator to only run in case 
another was false, you can use `:validat_with do ... end` in order to combine validators based on custom logic. 

 ```ruby
NxtSchema.root do
  required(:test, :Integer).validate_with do
    validator(:greater_than, 5) &&
      validator(:greater_than, 6) &&
      validator(:greater_than, 7)
  end
end
```

This has one drawback however. Let's say your test value is 4. This would only run your first validator and then exit 
from the logic since validators are combined with &&. In this example it might not make much sense, but it basically 
means that you might not have the full validation errors when combining validations with `:validate_with` 


### Schema options
 
#### Optional keys strategies

Schemas in NxtSchema only look at the keys that you have defined in your schema, others are ignored per default.
You can change this behaviour by providing a strategy for the `:additional_keys` option. 

```ruby
# This will simply ignore any other key except test 
NxtSchema.root(additional_keys: :ignore) do
  required(:test, :String) 
end

# This would give you an error in case you apply anything other than { test: '...' }
NxtSchema.root(additional_keys: :restrict) do
  required(:test, :String) 
end

# This will merge other keys into your output
schema = NxtSchema.root(additional_keys: :allow) do
  required(:test, :String) 
end

schema.apply(test: 'getsafe', other: 'Heidelberg')
schema.valid? # => true
schema.value # => { test: 'getsafe', other: 'Heidelberg' }
```

#### Transform keys

You may want to transform the keys from your input. Therefore specify the transform_keys option. This might be useful
when you want your schema to return only symbolized keys for example. 

```ruby
schema = NxtSchema.root(transform_keys: :to_sym) do
  required(:test, :String)
end

schema.apply('test' => 'getsafe') # => {:test=>"getsafe"}
schema.apply(test: 'getsafe') # => {:test=>"getsafe"}
``` 

#### Adding meta data to nodes

You want to give nodes an ID or some other meta data? You can use the meta method on nodes for adding additional 
information onto any node.  

```ruby
schema = NxtSchema.root do
  ERROR_MESSAGES = {
    test: 'This is always broken'
  }

  required(:test, :String).meta(ERROR_MESSAGES).validate ->(node) { node.add_error(node.meta.fetch(node.name)) }
end

schema.apply(test: 'getsafe') 
schema.error #  {"root.test"=>["This is always broken"]}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/nxt_schema.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

### TODO:    

- Flatten schema errors like validation errors
- Conditionally required keys:
    required bool => required
    required conditionally => condition applies => required
    required conditionally => condition does not apply => not allowed 
    
- Explain the difference between array nodes and typed array nodes
- Should we translate coercion errors as well?
- Test the different scenarios of merging schemas array, hash, ...
- Structure Errors 
- NxtSchema::Json => Use json types, maybe even parse Json with Oj
