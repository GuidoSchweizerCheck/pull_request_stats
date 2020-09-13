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
      @repositories = Repository.order(:id).all

      view(:index)
    end

    r.get("all") do
      @developers = Developer.all
      @pull_request_counts = PullRequest.group_and_count_by_author
      @reviews = Review.distinct_pull_request_reviews.group_and_count_by_author

      view(:repository)
    end

    r.get("all", Integer) do |year|
      @developers = Developer.all
      @pull_request_counts = PullRequest.in_year(year).group_and_count_by_author
      @reviews = Review.in_year(year).distinct_pull_request_reviews
        .group_and_count_by_author

      view(:repository)
    end

    r.get(String, String) do |owner, name|
      @repository = Repository.first(owner: owner, name: name)
      @developers = Developer.all
      @pull_request_counts = PullRequest.for_repository(@repository)
        .group_and_count_by_author
      @reviews = Review.distinct_pull_request_reviews(repository_id: @repository.id)
        .group_and_count_by_author

      view(:repository)
    end

    r.get(String, String, Integer) do |owner, name, year|
      @repository = Repository.first(owner: owner, name: name)
      @developers = Developer.all
      @pull_request_counts = PullRequest.in_year(year).for_repository(@repository)
        .group_and_count_by_author
      @reviews = Review.in_year(year)
        .distinct_pull_request_reviews(repository_id: @repository.id)
        .group_and_count_by_author

      view(:repository)
    end
  end
end
