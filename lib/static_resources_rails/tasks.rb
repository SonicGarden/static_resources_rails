namespace :static_resources do
  desc 'Sync public/{packs,assets} to s3'
  task sync_s3: :environment do
    require 'open3'

    env = {
      'AWS_ACCESS_KEY_ID' => ENV['STATIC_RESOURCES_AWS_ACCESS_KEY_ID'],
      'AWS_SECRET_ACCESS_KEY' => ENV['STATIC_RESOURCES_AWS_SECRET_KEY_ID'],
    }
    max_age = 86400 * 365

    %w[packs assets].each do |dir|
      command = "aws s3 sync public/#{dir} s3://#{StaticResourcesRails.bucket}/#{dir} --cache-control 'max-age=#{max_age}'"
      stdout, stderror, status = Open3.capture3(env, command)

      unless status.exitstatus.zero?
        raise "#{dir} の aws s3 syncが正常に終了しませんでした。標準出力:#{stdout} 標準エラー：#{stderror} ステータス：#{status}"
      end
    end
  end

  desc 'Download webpacker manifest.json'
  task download_webpacker_manifest: :environment do
    manifest_path = 'packs/manifest.json'
    download_url = "https://#{Rails.application.config.action_controller.asset_host}/#{manifest_path}"
    public_file_path = Rails.public_path.join(manifest_path)
    public_file_path.parent.mkdir unless public_file_path.parent.exist?

    IO.write(public_file_path, URI.open(download_url).read)
  end
end

if %w[no false n f].include?(ENV['WEBPACKER_PRECOMPILE'])
  Rake::Task['assets:precompile'].enhance(['static_resources:download_webpacker_manifest'])
end
