require 'aws-sdk-s3'
require 'fileutils'
require 'mime/types'

module StaticResourcesRails
  class Storage
    def self.sync(dir)
      new(StaticResourcesRails.region, StaticResourcesRails.bucket, dir).sync
    end

    def initialize(region, bucket_name, dir)
      @region = region
      @bucket_name = bucket_name
      @dir = dir
    end

    def sync
      dir = Rails.public_path.join(@dir)
      return unless dir.directory?

      dir.find do |path|
        next if path.directory?

        upload_file(path)
      end
    end

    private

    def upload_file(path)
      max_age = 86400 * 365
      gzipped = "#{path.to_s}.gz"
      options = {
        cache_control: "max-age=#{max_age}",
        content_type: ::MIME::Types.type_for(path.extname).first.to_s,
      }

      if File.exist?(gzipped)
        FileUtils.cp(gzipped, path.to_s)
        options[:content_encoding] = 'gzip'
        log "Uploading #{gzipped} in place of #{path}"
      end

      object = bucket.object(path_to_key(path))
      object.upload_file(path.to_s, options)
      log "Uploaded #{path}"
    end

    def path_to_key(path)
      path.relative_path_from(Rails.public_path).to_s
    end

    def bucket
      @bucket ||= Aws::S3::Resource.new(region: @region).bucket(@bucket_name)
    end

    def log(message)
      Rails.logger.debug(message)
    end
  end
end
