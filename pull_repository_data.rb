class PullRepositoryData
  def initialize(repository)
    @repository = repository
    @last_pull = repository.updated_at
    @raw_pull_request_data = []
    @pull_requests = []
    @developers = Set.new
    @reviews = []
  end

  def call
    crawl_pull_requests
    extract_data
    save_data
    repository.touch
  end

  private

  attr_reader :repository, :last_pull, :raw_pull_request_data, :pull_requests,
    :developers, :reviews

  def crawl_pull_requests
    cursor = nil

    loop do
      data = query(cursor).data
      page_info = data.repository.pull_requests.page_info

      raw_pull_request_data.concat(data.repository.pull_requests.nodes)
      last_updated_at = Time.parse(raw_pull_request_data.last.updated_at)

      break unless page_info.has_next_page
      break if last_pull && last_updated_at < last_pull

      cursor = page_info.end_cursor
    end
  end

  def query(cursor)
    GithubClient.query(PullRequestsQuery, variables: {
      repositoryOwner: repository.owner,
      repositoryName: repository.name,
      after: cursor
    })
  end

  def extract_data
    raw_pull_request_data.each do |pull_request_data|
      pull_requests << map_pull_request(pull_request_data)
      developers << map_developer(pull_request_data.author)

      pull_request_data.reviews.nodes.each do |review_data|
        developers << map_developer(review_data.author)
        reviews << map_review(review_data, pull_request_data)
      end
    end
  end

  def map_pull_request(data)
    { id: data.id, repository_id: repository.id,
      author_id: data.author.id, number: data.number, title: data.title,
      created_at: data.created_at, updated_at: data.updated_at }
  end

  def map_developer(data)
    { id: data.id, login: data.login, avatar_url: data.avatar_url,
      created_at: data.created_at, updated_at: data.updated_at }
  end

  def map_review(data, pull_request_data)
    { id: data.id, pull_request_id: pull_request_data.id,
      author_id: data.author.id, created_at: data.created_at,
      updated_at: data.updated_at }
  end

  def save_data
    DB[:developers].insert_conflict(
      constraint: :developers_login_key,
      update: {
        avatar_url: Sequel[:excluded][:avatar_url],
        updated_at: Sequel[:excluded][:updated_at]
      }
    ).multi_insert(developers)

    DB[:pull_requests].insert_conflict(
      constraint: :pull_requests_pkey,
      update: {
        title: Sequel[:excluded][:title],
        updated_at: Sequel[:excluded][:updated_at]
      }
    ).multi_insert(pull_requests)

    DB[:reviews].insert_conflict(
      constraint: :reviews_pkey,
      update: { updated_at: Sequel[:excluded][:updated_at] }
    ).multi_insert(reviews)
  end
end
