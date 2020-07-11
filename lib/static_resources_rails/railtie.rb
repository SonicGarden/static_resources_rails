module StaticResourcesRails
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load 'static_resources_rails/tasks.rb'
    end
  end
end
