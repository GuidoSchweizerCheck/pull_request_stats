require "dotenv/load" unless ENV["RACK_ENV"] == "production"
require "roda"
require "tilt"

require "./app/db"
require "./app/github_client"
require "./app/pull_request_query"
require "./app/models"
require "./app/pull_repository_data"
require "./app/repository_view"

class App < Roda
  plugin :render, engine: "html.erb", views: "app/views"

  if ENV["RACK_ENV"] == "production"
    use Rack::Auth::Basic, "Restricted Area" do |username, password|
      username == ENV.fetch("USERNAME") && password == ENV.fetch("PASSWORD")
    end
  end

  route do |r|
    r.root do
      @repositories = Repository.order(:id).all

      view(:index)
    end

    r.get("all") do
      @view = RepositoryView.new

      view(:repository)
    end

    r.get("all", Integer) do |year|
      @view = RepositoryView.new(nil, year)

      view(:repository)
    end

    r.get(String, String) do |owner, name|
      repository = Repository.first(owner: owner, name: name)
      @view = RepositoryView.new(repository)

      view(:repository)
    end

    r.get(String, String, Integer) do |owner, name, year|
      repository = Repository.first(owner: owner, name: name)
      @view = RepositoryView.new(repository, year)

      view(:repository)
    end
  end
end
