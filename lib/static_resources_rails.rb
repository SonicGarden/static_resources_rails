require "static_resources_rails/version"
require 'static_resources_rails/railtie'

module StaticResourcesRails
  class Error < StandardError; end
  class ManifestError < Error; end
  class SyncError < Error; end

  class << self
    attr_accessor :region, :sprockets_manifest_filename, :additional_manifest_files
    attr_reader :additional_sync_dirs

    def set_bucket(value, with_asset_host: true)
      @bucket = value
      if with_asset_host
        asset_host = ->(source) { asset_host_pattern.match?(source) ? bucket_host : nil }
        Rails.application.config.action_controller.asset_host = asset_host
        Rails.application.config.action_mailer.asset_host = asset_host

        # SEE: https://github.com/ElMassimo/vite_ruby/pull/203
        if defined?(ViteRuby)
          ENV['VITE_RUBY_ASSET_HOST'] = bucket_host
        end
      end
      Rails.application.config.assets.manifest = "public/assets/#{sprockets_manifest_filename}"
    end

    def bucket
      raise Error, 'bucket is empty!' unless @bucket

      @bucket
    end

    def bucket_host
      "#{bucket}.s3.#{region}.amazonaws.com"
    end

    def aseet_dirs
      ['assets', *additional_sync_dirs]
    end

    def asset_host_pattern
      @asset_host_pattern ||= %r|\A/#{Regexp.union(aseet_dirs)}/|
    end

    def additional_sync_dirs=(value)
      @additional_sync_dirs = value
      @asset_host_pattern = nil
    end
  end

  self.region = 'ap-northeast-1'
  # TODO: rename
  self.sprockets_manifest_filename = '.sprockets-manifest.json'
  self.additional_sync_dirs = []
  self.additional_manifest_files = []
end
