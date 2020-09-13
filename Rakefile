require "dotenv/load" unless ENV["RACK_ENV"] == "production"
require "rake"

namespace :db do
  desc "Migrate the database"
  task :migrate, [:version] do |t, args|
    require "sequel/core"
    require "./app/db"

    version = args[:version].to_i if args[:version]
    Sequel.extension(:migration)
    Sequel::Migrator.run(DB, "migrations", target: version)
  end
end

desc "Open IRB and require the app"
task :console do
  exec "irb -r ./app"
end

desc "Update data for all repositories"
task :update_data do
  require "./app"

  Repository.all.each do |repository|
    PullRepositoryData.new(repository).call
  end
end

desc "Dump Github's GraphQL schema"
task :dump_graphql_schema do
  require "./app/github_client"

  GraphQL::Client.dump_schema(GithubHTTP, __dir__ + "/app/github_schema.json")
end
