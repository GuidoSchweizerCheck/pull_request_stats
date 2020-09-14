class RepositoryView
  MONTH_NAMES = {
    1 => "January", 2 => "February", 3 => "March", 4 => "April",  5 => "May",
    6 => "June", 7 => "July", 8 => "August", 9 => "September", 10 => "October",
    11 => "November", 12 => "December"
  }

  def initialize(repository = nil, year = nil, month = nil)
    @repository = repository
    @year = year
    @month = month
  end

  def title
    parts = ["Stats for", repository&.key || "all Repositories"]
    parts.push("in") if year
    parts.push(MONTH_NAMES[month]) if month
    parts.push(year) if year

    parts.join(" ")
  end

  def developers
    Developer.all
  end

  def pull_request_counts
    PullRequest
      .then(&method(:in_year))
      .then(&method(:in_month))
      .then(&method(:for_repository))
      .group_and_count_by_author
  end

  def reviews
    Review
      .then(&method(:in_year))
      .then(&method(:in_month))
      .distinct_pull_request_reviews(repository_id: repository&.id)
      .group_and_count_by_author
  end

  private

  attr_reader :repository, :year, :month

  def in_year(dataset)
    optional_query(dataset, :in_year, year)
  end

  def in_month(dataset)
    optional_query(dataset, :in_month, month)
  end

  def for_repository(dataset)
    optional_query(dataset, :for_repository, repository)
  end

  def optional_query(dataset, query, value)
    value.nil? ? dataset : dataset.public_send(query, value)
  end
end
