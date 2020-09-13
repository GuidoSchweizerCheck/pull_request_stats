require "dotenv/load"
require "roda"
require "tilt"

require "./app/db"
require "./app/github_client"
require "./app/pull_request_query"
require "./app/models"
require "./app/pull_repository_data"

class App < Roda
  plugin :render, engine: "html.erb", views: "app/views"

  route do |r|
    r.root do
      view("index")
    end
  end
end
