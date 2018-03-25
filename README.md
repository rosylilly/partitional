# Partitional

[![Gem](https://img.shields.io/gem/v/partitional.svg)](https://rubygems.org/gems/partitional)
[![Build Status](https://travis-ci.org/rosylilly/partitional.svg?branch=master)](https://travis-ci.org/rosylilly/partitional)
[![Coverage Status](https://coveralls.io/repos/github/rosylilly/partitional/badge.svg?branch=master)](https://coveralls.io/github/rosylilly/partitional?branch=master)

Provides partial model to your Rails. Partial models are like a value object. You can add accessor, domain logics and validation to partial models.

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
  # `users` table has :email_local_part and :email_domain columns
  parition :email, prefix: :email # or mapping: { local_part: :email_local_part, domain: :email_domain }
end

# app/models/company.rb
class Company < ApplicationRecord
  # `companies` table has :contact_email_local_part, :contact_email_domain
  # :payment_email_local_part and :payment_email_domain columns

  partition :contact_email, class_name: 'Email', prefix: :contact_email
  partition :payment_email, class_name: 'Email', prefix: :payment_email
end

# app/models/email.rb
class Email < Partitional::Model
  attr_accessor :local_part, :domain

  validates :local_part, format: /\A[a-zA-Z0-9_-]{1,255}\z/
  validates :domain, format: /\A[a-zA-Z0-9]{2,}(?:\.[a-zA-Z0-9]{2,})+\z/

  def to_s
    "#{local_part}@#{domain}"
  end
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
