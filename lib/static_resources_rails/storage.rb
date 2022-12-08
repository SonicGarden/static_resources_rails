require 'aws-sdk-s3'
require 'fileutils'
require 'mime/types'
require 'concurrent-ruby'

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
      upload_files(all_files)
    end

    private

    def all_files
      Rails.public_path.join(@dir).find.reject(&:directory?)
    end

    def upload_files(files)
      ordered_by_size_files = files.sort { |a, b| b.size - a.size }
      uploader = Uploader.new(bucket)
      ordered_by_size_files.each do |path|
        uploader.upload(path)
      end
      uploader.wait_until_done
    end

    def bucket
      @bucket ||= Aws::S3::Resource.new(region: @region).bucket(@bucket_name)
    end

    class Uploader
      def initialize(bucket)
        @bucket = bucket
      end

      def upload(path)
        executor.post do
          upload_file(path)
        end
      end

      def wait_until_done
        executor.shutdown
        executor.wait_for_termination
      end

      private

      def executor
        @executor ||= Concurrent::CachedThreadPool.new
      end

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

        object = @bucket.object(path_to_key(path))
        object.upload_file(path.to_s, options)
        log "Uploaded #{path}"
      end

      def path_to_key(path)
        path.relative_path_from(Rails.public_path).to_s
      end

      def log(message)
        Rails.logger.debug(message)
      end
    end
  end
end
