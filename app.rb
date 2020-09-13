require "dotenv/load" unless ENV["RACK_ENV"] == "production"
require "roda"
require "tilt"

require "./app/db"
require "./app/github_client"
require "./app/pull_request_query"
require "./app/models"
require "./app/pull_repository_data"

class App < Roda
  plugin :render, engine: "html.erb", views: "app/views"

  if ENV["RACK_ENV"] == "production"
    use Rack::Auth::Basic, "Restricted Area" do |username, password|
      username == ENV.fetch("USERNAME") && password == ENV.fetch("PASSWORD")
    end
  end

  route do |r|
    r.root do
      @developers = Developer.all
      @pull_request_counts = PullRequest
        .group_and_count(:author_id).order(:count).reverse.all
      @reviews = Review.distinct_pull_request_reviews
        .group_and_count(:author_id).order(:count).reverse.all

      view("index")
    end
  end
end
