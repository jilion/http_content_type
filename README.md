# HttpContentType
[![Gem Version](https://badge.fury.io/rb/http_content_type.png)](http://badge.fury.io/rb/http_content_type) [![Build Status](https://travis-ci.org/jilion/http_content_type.png?branch=master)](https://travis-ci.org/jilion/http_content_type) [![Dependency Status](https://gemnasium.com/jilion/http_content_type.png)](https://gemnasium.com/jilion/http_content_type) [![Code Climate](https://codeclimate.com/github/jilion/http_content_type.png)](https://codeclimate.com/github/jilion/http_content_type) [![Coverage Status](https://coveralls.io/repos/jilion/http_content_type/badge.png?branch=master)](https://coveralls.io/r/jilion/http_content_type)

This gem allows you to check the Content-Type of any asset accessible via HTTP.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'http_content_type'
```
And then execute:

```shell
$ bundle
```

Or install it yourself as:

```shell
$ gem install http_content_type
```

## Usage

```ruby
checker = HttpContentType::Checker.new('http://domain.com/video.mp4')

checker.found?                # => true (asset doesn't return a 404)
checker.expected_content_type # => 'video/mp4' (the expected content type is based on file extension)
checker.content_type          # => 'video/mp4'
checker.valid_content_type?   # => true
```

## Development

* Documentation hosted at [RubyDoc](http://rubydoc.info/github/jilion/http_content_type/master/frames).
* Source hosted at [GitHub](https://github.com/jilion/http_content_type).

Pull requests are very welcome! Please try to follow these simple rules if applicable:

* Please create a topic branch for every separate change you make.
* Make sure your patches are well tested. All specs must pass on [Travis CI](https://travis-ci.org/jilion/http_content_type).
* Update the [Yard](http://yardoc.org/) documentation.
* Update the [README](https://github.com/jilion/http_content_type/blob/master/README.md).
* Update the [CHANGELOG](https://github.com/jilion/http_content_type/blob/master/CHANGELOG.md) for noteworthy changes (don't forget to run `bundle exec pimpmychangelog` and watch the magic happen)!
* Please **do not change** the version number.

### Author

* [Rémy Coutable](https://github.com/rymai) ([@rymai](http://twitter.com/rymai), [rymai.me](http://rymai.me))

### Contributors

[https://github.com/jilion/http_content_type/graphs/contributors](https://github.com/jilion/http_content_type/contributors)
