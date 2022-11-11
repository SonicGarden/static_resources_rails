require "static_resources_rails/version"
require 'static_resources_rails/railtie'

module StaticResourcesRails
  class Error < StandardError; end
  class ManifestError < Error; end
  class SyncError < Error; end

  class << self
    attr_accessor :region, :sprockets_manifest_filename, :additional_sync_dirs, :additional_manifest_files

    def bucket=(value)
      @bucket = value
      asset_host = "#{@bucket}.s3.#{region}.amazonaws.com"
      Rails.application.config.action_controller.asset_host = asset_host
      Rails.application.config.action_mailer.asset_host = asset_host
      Rails.application.config.assets.manifest = "public/assets/#{sprockets_manifest_filename}"
    end

    def bucket
      raise Error, 'bucket is empty!' unless @bucket

      @bucket
    end
  end

  self.region = 'ap-northeast-1'
  self.sprockets_manifest_filename = '.sprockets-manifest.json'
  self.additional_sync_dirs = []
  self.additional_manifest_files = []
end
