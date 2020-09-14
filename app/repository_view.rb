class RepositoryView
  def initialize(repository = nil, year = nil)
    @repository = repository
    @year = year
  end

  def title
    parts = ["Stats for", repository&.key || "all Repositories"]

    parts.push("in #{year}") if year

    parts.join(" ")
  end

  def developers
    Developer.all
  end

  def pull_request_counts
    PullRequest
      .then(&method(:in_year))
      .then(&method(:for_repository))
      .group_and_count_by_author
  end

  def reviews
    Review
      .then(&method(:in_year))
      .distinct_pull_request_reviews(repository_id: repository&.id)
      .group_and_count_by_author
  end

  private

  attr_reader :repository, :year

  def in_year(dataset)
    year.nil? ? dataset : dataset.in_year(year)
  end

  def for_repository(dataset)
    repository.nil? ? dataset : dataset.for_repository(repository)
  end
end
