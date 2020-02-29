# NxtSchema

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/nxt_schema`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO:    
======================================================
Only assign values after subtree has been applied!!!! <- Check whether this was done?!
======================================================

- Find a sane way to differentiate between input and output value 
- Implement proper schema and validation error system that would be capable of I18n and custom error messages
- Resolve custom types from type namespace and fallback to default type system
- Test the different scenarios of merging schemas array, hash, ...
- Test all methods of all nodes
    => Structure tests by nodes and method
    
- Think about how we want to handle additional keys in schemas
    - slice additional values away
    - tolerate extra values and do not type cast 
    - raise an error if there are keys not from the schema

- Test if context is passed down to all nodes
- Spec the different type systems

- Types
    => Implement maybe for types
    => Implement default for types => When value is not present return default
    
- Implement optional keys for all nodes 
    => Not sure it makes sense for nodes where the parent is not a schema
    => We might actually want to prevent optional nodes in non schema situations?
    
- Implement defaults for all nodes
- Should there be a `default(:email, :String).default(andreas@robecke.de)` 
    --> Would mean that the key is always in the schema, also when not provided and defaults to the specified default value.
    But can be set when provided with another value.  
- Validator Registry
    => Allow chaining validations?
- Structure Errors 
- NxtSchema::Params => Use param types
- NxtSchema::Json => Use json types, maybe even parse Json with Oj
- Default options for schemas?
- What about transforming keys?
- Should we allow to pass in meta data to any node - would be kind of nice to be able to access it
    required(:name, :String).meta(internal: true, required_for_pricing: true) 
    required(:tariff, Enum()).meta(internal: true, required_for_pricing: true) 
 

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
schema = NxtSchema.schema(:company) do 
  requires(:name, :String)  
  requires(:value, :Integer).maybe(nil)  
  requires(:in_insure_tech, :Bool).default(false)
  
  hash(:address) do
    requires(:street, :String)
    requires(:street_number, :Integer)
  end
    
  array(:employees) do
    hash(:employee) do
      requires(:first_name, :String)
      requires(:last_name, :String)
      optional(:email, :String).validate(
        lambda do |node|
          if node[:email] && !node[:email].include?('@')
            node.add_error("Email not valid: #{node[:email]}")  
          end
        end
      )
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

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/nxt_schema.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
