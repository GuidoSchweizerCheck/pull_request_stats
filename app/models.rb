Sequel::Model.unrestrict_primary_key

class Repository < Sequel::Model
  plugin :timestamps
  plugin :touch

  one_to_many :pull_requests
end

class PullRequest < Sequel::Model
  many_to_one :repository
  many_to_one :author, class: :Developer
end

class Review < Sequel::Model
  many_to_one :pull_request
  many_to_one :author, class: :Developer

  def self.distinct_pull_request_reviews
    DB["SELECT pull_request_id, author_id FROM reviews GROUP BY pull_request_id, author_id"]
  end
end

class Developer < Sequel::Model
  one_to_many :pull_requests
end
