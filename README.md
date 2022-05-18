# SnFoil

![build](https://github.com/limited-effort/snfoil/actions/workflows/main.yml/badge.svg) [![maintainability](https://api.codeclimate.com/v1/badges/86e0b2490738e140f2e2/maintainability)](https://codeclimate.com/github/limited-effort/snfoil/maintainability)

SnFoil has been broken into smaller modules.  This gem serves to combine the most common gems in the SnFoil family and add some additional CRUD behavior.

This gem only uses [contexts](https://github.com/limited-effort/snfoil-context), [policies](https://github.com/limited-effort/snfoil-policy), and [searchers](https://github.com/limited-effort/snfoil-searcher) but you can check out all our modules here:
- [Contexts](https://github.com/limited-effort/snfoil-context) - Pipelined Business Logic
- [Controllers](https://github.com/limited-effort/snfoil-controller) - Separate HTTP Logic
- [Policies](https://github.com/limited-effort/snfoil-policy) - Authorization Checks
- [Rails](https://github.com/limited-effort/snfoil-rails) - Ruby on Rails Fluff
- [Searchers](https://github.com/limited-effort/snfoil-searcher) - Intuitive Search Classes

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'snfoil'
```
## Usage

### Contexts

There is where the magic of the original gem started.  The idea was to make a pipleline of logic that you could "plug" into certain intervals at.  You can find the [full documentation for contexts here](https://github.com/limited-effort/snfoil-context).

SnFoil adds six CRUD-centeric contexts prewired to get you off the ground as fast as possible. Each context sets up intervals for you, and generally follow the same pattern for calls: `setup`, `setup_<action>`, `before_<action>`, `after_<action>_success`, `after_<action>_failure`, and `after_<action>`.  You can find more information about each by clicking their respective links.
- [SnFoil::CRUD::BuildContext](docs/build-context.md) - for setting up an object.
- [SnFoil::CRUD::CreateContext](docs/create-context.md) - for setting up and saving an object to a data source.
- [SnFoil::CRUD::DestroyContext](docs/destroy-context.md) - find and destroy an object
- [SnFoil::CRUD::IndexContext](docs/index-context.md) - query for objects
- [SnFoil::CRUD::ShowContext](docs/show-context.md) - find an object
- [SnFoil::CRUD::UpdateContext](docs/update-context.md) find and update an object

You can pick and choose which features you want to use by including the specific file

```ruby
require 'snfoil/crud/index_context'
require 'snfoil/crud/show_context'

class PeopleContext
  include SnFoil::CRUD::IndexContext
  include SnFoil::CRUD::ShowContext

  # hooks and methods here
end
```

Or you can add all them in one go with `SnFoil::CRUD::Context`.

```ruby
require 'snfoil/crud/context'

class PeopleContext
  include SnFoil::CRUD::Context

  # hooks and methods here
end
```

### ORM Adapters

In order to be able to work with multiple data sources SnFoil allows you to create adapters for interacting with object. Adapters are just wrapper for your objects that add specific functionality needed by the base `SnFoil::CRUD` methods.  SnFoil handles the wrapping and unwrapping for you under the hood.

We created an adapter for `ActiveRecord` for you, but you can also create your own by inheriting from `SnFoil::Adapters::ORMs::BaseAdapter`.

Just make sure your adapter defines the following methods:
- `new` - method to create a new datasource object.  This should not commit to the data source
- `all` - method to grab all of a type from the data source
- `save` - method to commit an object to the data source
- `destroy` - method to remove an object from the data source
- `attributes=` - method for assigning a hash of attributes to the object

You can set your custom adapter by directly assigning it

```ruby
SnFoil.orm = CustomAdapter
```

Or if you prefer an initializer style

```ruby
SnFoil.configure do |config|
  config.orm = CustomAdapter
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/limited-effort/snfoil. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/limited-effort/snfoil/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [Apache 2 License](https://opensource.org/licenses/Apache-2.0).

## Code of Conduct

Everyone interacting in the Snfoil::Context project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/limited-effort/snfoil/blob/main/CODE_OF_CONDUCT.md).