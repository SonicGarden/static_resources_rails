# StaticResourcesRails

Delivering static resources from s3.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'static_resources_rails', github: 'SonicGarden/static_resources_rails'
```

And then execute:

    $ bundle install

## Usage

In `config/initializers/static_resources_rails.rb`
```ruby
buckets = {
  staging: 'static-resources-staging',
  production: 'static-resources-production',
}

if buckets.key?(Rails.env.to_sym)
  StaticResourcesRails.bucket = buckets[Rails.env.to_sym]
end
```

Set the following environment variables.
```
WEBPACKER_PRECOMPILE=false
```

## Tasks

### `static_resources:sync_s3`

*Required Env*

- STATIC_RESOURCES_AWS_ACCESS_KEY_ID
- STATIC_RESOURCES_AWS_SECRET_KEY_ID


### `static_resources:download_webpacker_manifest`

## GitHub Actions

TODO...
