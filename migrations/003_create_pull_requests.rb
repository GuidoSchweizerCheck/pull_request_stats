Sequel.migration do
  change do
    create_table(:pull_requests) do
      primary_key :id
      foreign_key :repository_id, :repositories, null: false
      foreign_key :author_id, :developers, null: false
      Integer :number, null: false
      String :title, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end
