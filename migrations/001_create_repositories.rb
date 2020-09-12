Sequel.migration do
  change do
    create_table(:repositories) do
      primary_key :id

      String :owner, null: false
      String :name, null: false
      DateTime :created_at, null: false
      DateTime :updated_at
    end
  end
end
