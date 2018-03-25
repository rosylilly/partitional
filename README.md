# Partitional

Provides partial model to your Rails.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'partitional'
```

And then execute:

    $ bundle

## Usage


```ruby
class ApplicationRecord
  include Partitional # Add this line to `app/models/application_record.rb`
end
```

### Example: E-Mail partition

```ruby
# app/models/user.rb
class User < ApplicationRecord
  # `users` table has :email_local_part and :email_domain column
  parition :email, class_name: 'Email', prefix: :email # or mapping: { local_part: :email_local_part, domain: :email_domain }
end

# app/models/email.rb
class Email < Partitional::Model
  attr_accessor :local_part, :domain

  validates :local_part, format: /\A[a-zA-Z0-9_-]{1,255}\z/
  validates :domain, format: /\A[a-zA-Z0-9]{2,}(?:\.[a-zA-Z0-9]{2,})+\z/
end

# in some code
user = User.find(1)
user.email.local_part = "test"
user.email.domain = "example.com"
user.valid? # => true

user.email.domain = "!!!!"
user.valid? # => false
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/rosylilly/partitional.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
