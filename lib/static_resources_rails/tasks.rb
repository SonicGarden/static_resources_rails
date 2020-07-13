namespace :static_resources do
  desc 'Sync public/{packs,assets} to s3'
  task sync_s3: :environment do
    require 'open3'

    env = {
      'AWS_ACCESS_KEY_ID' => ENV.fetch('STATIC_RESOURCES_AWS_ACCESS_KEY_ID'),
      'AWS_SECRET_ACCESS_KEY' => ENV.fetch('STATIC_RESOURCES_AWS_SECRET_KEY_ID'),
    }
    max_age = 86400 * 365

    %w[packs assets].each do |dir|
      command = "aws s3 sync public/#{dir} s3://#{StaticResourcesRails.bucket}/#{dir} --cache-control 'max-age=#{max_age}'"
      stdout, stderror, status = Open3.capture3(env, command)

      unless status.exitstatus.zero?
        raise StaticResourcesRails::SyncError, stderror
      end
    end
  end

  desc 'Download manifest.json'
  task download_manifest: :environment do
    unless Rails.application.config.assets.manifest
      raise StaticResourcesRails::ManifestError, 'config.assets.manifest is blank!'
    end

    manifest_files = ["assets/#{StaticResourcesRails.sprockets_manifest_filename}", 'packs/manifest.json']

    manifest_files.each do |manifest_file|
      download_url = "https://#{Rails.application.config.action_controller.asset_host}/#{manifest_file}"
      file_path = Rails.public_path.join(manifest_file)
      file_path.parent.mkdir unless file_path.parent.exist?
      IO.write(file_path, URI.open(download_url).read)
    end
  end
end
