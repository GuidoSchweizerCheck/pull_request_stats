Sequel::Model.unrestrict_primary_key

module SequelQueries
  def self.included(base)
    base.class_eval do
      dataset_module do
        def group_and_count_by_author
          group_and_count(:author_id).order(:count).reverse.all
        end

        def in_year(year)
          in_time("year", year)
        end

        def in_month(month)
          in_time("month", month)
        end

        def in_time(name, value)
          condition = "EXTRACT(#{name} from #{first_source_table}.created_at) = ?"

          where(Sequel.lit(condition, value))
        end
      end
    end
  end
end

class Repository < Sequel::Model
  plugin :timestamps
  plugin :touch

  one_to_many :pull_requests

  def key
    "#{owner}/#{name}"
  end

  def years_and_months
    PullRequest.where(repository_id: id).years_and_months
  end
end

class PullRequest < Sequel::Model
  include SequelQueries

  many_to_one :repository
  many_to_one :author, class: :Developer

  dataset_module do
    def for_repository(repository)
      where(repository_id: repository.id)
    end

    def years_and_months
      order(:year, :month).reverse.distinct.select_map([
        Sequel.lit("DATE_PART('year', created_at)::int").as(:year),
        Sequel.lit("DATE_PART('month', created_at)::int").as(:month)
      ]).each_with_object({}) do |(year, month), hash|
        hash[year] ||= []
        hash[year] << month
      end
    end
  end
end

class Review < Sequel::Model
  include SequelQueries

  many_to_one :pull_request
  many_to_one :author, class: :Developer

  dataset_module do
    def distinct_pull_request_reviews(repository_id: nil)
      dataset = join(:pull_requests, id: :pull_request_id)
        .where(Sequel.lit("pull_requests.author_id != reviews.author_id"))

      dataset = dataset.where(repository_id: repository_id) if repository_id

      dataset.group(:pull_request_id, Sequel[:reviews][:author_id])
        .distinct
        .select(:pull_request_id, Sequel[:reviews][:author_id])
        .from_self
    end
  end
end

class Developer < Sequel::Model
  one_to_many :pull_requests
end
