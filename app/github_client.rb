require "graphql/client"
require "graphql/client/http"

GithubHTTP = GraphQL::Client::HTTP.new("https://api.github.com/graphql") do
  def headers(context)
    { "Authorization": "bearer #{ENV.fetch('GITHUB_API_TOKEN')}" }
  end
end

GithubSchema = GraphQL::Client.load_schema(__dir__ + "/github_schema.json")
GithubClient = GraphQL::Client.new(schema: GithubSchema, execute: GithubHTTP)
