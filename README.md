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

In `config/environments/production.rb`

```ruby
StaticResourcesRails.set_bucket('static-resources-production')
```

If you want to skip using the S3 bucket host as `asset_host`:

```ruby
StaticResourcesRails.set_bucket('static-resources-production', with_asset_host: false)
```

### Before deploying

```
bin/rake assets:precompile
bin/rake static_resources:sync_s3
```

### After deployment

```
bin/rake static_resources:download_manifest
```

### With vite_rails

`vite.config.ts`
```javascript
import gzipPlugin from 'rollup-plugin-gzip'
import { defineConfig } from 'vite'
import RubyPlugin from 'vite-plugin-ruby'

const isDistEnv = process.env.RAILS_ENV === 'production' || process.env.RAILS_ENV === 'staging'

export default defineConfig({
  plugins: [
    RubyPlugin(),
    isDistEnv && gzipPlugin(),
  ],
})

```

`config/initializers/static_resources_rails.rb`
```ruby
StaticResourcesRails.additional_sync_dirs = %w[vite]
StaticResourcesRails.additional_manifest_files = %w[vite/manifest.json vite/manifest-assets.json]
```

### With webpacker

`config/initializers/static_resources_rails.rb`
```ruby
StaticResourcesRails.additional_sync_dirs = %w[packs]
StaticResourcesRails.additional_manifest_files = %w[packs/manifest.json]
```

## Tasks

### `static_resources:sync_s3`

_Required Env_

- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY

### `static_resources:download_manifest`

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
          AWS_ACCESS_KEY_ID: ${{ secrets.STATIC_RESOURCES_AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.STATIC_RESOURCES_AWS_SECRET_KEY_ID }}
        run: bundle exec rake static_resources:sync_s3
```

## With OpsWorks

Skip `assets:precompile` on deploying. Add below lines to Layer's Custom JSON:

```
{
    "deploy": {
        "YOUR_APP_NAME": {
            "framework": {
                "assets_precompile": false
            }
        }
    }
}
```
