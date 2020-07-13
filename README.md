# StaticResourcesRails

Delivering static resources from s3.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'static_resources_rails', github: 'SonicGarden/static_resources_rails'
```

And then execute:

    $ bundle install

## Required

- [aws/aws\-cli: Universal Command Line Interface for Amazon Web Services](https://github.com/aws/aws-cli)

## Usage

In `config/initializers/static_resources_rails.rb`
```ruby
buckets = {
  staging: 'static-resources-staging',
  production: 'static-resources-production',
}

if buckets.key?(Rails.env.to_sym)
  StaticResourcesRails.bucket = buckets[Rails.env.to_sym]
  Rails.application.config.assets.manifest = 'public/assets/.sprockets-manifest.json'
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

In `.github/workflows/deploy.yml`

```yaml
name: Release
on:
  push:
    branches:
      - master
  workflow_dispatch:

jobs:
  sync_s3:
    runs-on: ubuntu-latest
    env:
      RAILS_ENV: production
      NODE_ENV: production
      DISABLE_SPRING: 1
      DATABASE_URL: postgresql://dummy:dummy@localhost:5432/postgres?encoding=utf8&pool=5&timeout=5000
      SECRET_KEY_BASE: dummy

    steps:
      - uses: actions/checkout@v2

      - uses: actions/setup-node@v1
        with:
          node-version: 10

      - uses: SonicGarden/setup-yarn-action@v1

      - uses: ruby/setup-ruby@v1
        with:
          bundler-cache: true

      - uses: SonicGarden/webpacker-compile-action@v1
        with:
          cachePaths: |
            public/assets
            public/packs
          compileCommand: bundle exec rake assets:precompile

      - name: sync s3
        env:
          STATIC_RESOURCES_AWS_ACCESS_KEY_ID: ${{ secrets.STATIC_RESOURCES_AWS_ACCESS_KEY_ID }}
          STATIC_RESOURCES_AWS_SECRET_KEY_ID: ${{ secrets.STATIC_RESOURCES_AWS_SECRET_KEY_ID }}
        run: bundle exec rake static_resources:sync_s3
```
