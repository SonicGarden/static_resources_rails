namespace :static_resources do
  desc 'Sync public/{packs,assets} to s3'
  task sync_s3: :environment do
    require 'static_resources_rails/storage'

    %w[packs assets].each do |dir|
      StaticResourcesRails::Storage.sync(dir)
    end
  end

  desc 'Download manifest.json'
  task download_manifest: :environment do
    unless Rails.application.config.assets.manifest
      raise StaticResourcesRails::ManifestError, 'config.assets.manifest is blank!'
    end

    manifest_files = ["assets/#{StaticResourcesRails.sprockets_manifest_filename}", 'packs/manifest.json']

    manifest_files.each do |manifest_file|
      download_url = "#{Rails.application.config.action_controller.asset_host}/#{manifest_file}"
      file_path = Rails.public_path.join(manifest_file)
      file_path.parent.mkdir unless file_path.parent.exist?
      IO.write(file_path, URI.open(download_url).read)
    end
  end
end
