require 'logger'
require 'date'
require 'yaml'

RACK_ENV  = ENV["RACK_ENV"] || ENV["SINATRA_ENV"] || "development"
DB_CONFIG = YAML.load(File.open('config/database.yml', &:read))[RACK_ENV]

namespace :db do
  task :environment do
    require 'active_record'
    ActiveRecord::Base.establish_connection(DB_CONFIG)
  end

  desc "Migrate the database"
  task :migrate => :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
  end
end

namespace :generate do
  task :migration do
    time = DateTime.now.strftime("%Y%m%d%H%M%S")
    name = "#{time}_NAME"
    `touch db/migrate/#{name}.rb`
  end
end