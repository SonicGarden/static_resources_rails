require "static_resources_rails/version"
require 'static_resources_rails/railtie'

module StaticResourcesRails
  class Error < StandardError; end

  class << self
    def bucket=(value)
      @bucket = value
      Rails.application.config.action_controller.asset_host = "#{@bucket}.s3.ap-northeast-1.amazonaws.com"
    end

    def bucket
      raise Error, 'bucket is empty!' unless @bucket

      @bucket
    end
  end
end
