Sequel.migration do
  change do
    create_table(:reviews) do
      primary_key :id
      foreign_key :pull_request_id, :pull_requests, null: false
      foreign_key :author_id, :developers, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end
