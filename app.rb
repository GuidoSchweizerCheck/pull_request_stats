require "dotenv/load"
require "roda"
require "tilt"

require "./db"
require "./github_client"
require "./pull_request_query"
require "./models"
require "./pull_repository_data"

class App < Roda
  plugin :render, engine: "html.erb"

  route do |r|
    r.root do
      view("index")
    end
  end
end
