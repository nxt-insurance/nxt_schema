# NxtSchema

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/nxt_schema`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO:    
======================================================
Only assign values after subtree has been applied!!!!
======================================================

- Can we use dry types for the type system?
- Test the different scenarios of merging schemas array, hash, ...
- Test all methods of all nodes
    => Structure tests by nodes and method
- Merge errors of array nodes with multiple schemas
- Types
    => Implement maybe for types
    => Implement default for types
- Implement optional keys for all nodes
- Implement defaults for all nodes
- Validator Registry
    => Allow chaining validations?
- Type Registry
- Structure Errors
- Enforce uniqueness of names of multiple schemas in array nodes?!
- Can we have nodes in the schema depending on others => One node is required / optional if the other is present or contains a certain value?
- Type system per Schema? - Could even be per node => type_system: Type::Strict 
    - NxtSchema::Params => Use param types
    - NxtSchema::Json => Use json types, maybe even parse Json with Oj
- Default options for schemas?
 

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
schema = NxtSchema.hash(:company) do 
  requires(:name, :String)  
  requires(:value, :Integer).maybe(nil)  
  requires(:in_insure_tech, :Boolean).default(false)
  
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
