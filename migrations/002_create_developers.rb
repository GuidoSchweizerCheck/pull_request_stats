Sequel.migration do
  change do
    create_table(:developers) do
      primary_key :id

      String :login, null: false, unique: true
      String :avatar_url, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end
