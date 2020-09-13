require "sequel"

DATABASE_URL = ENV.fetch("DATABASE_URL")

DB = Sequel.connect(DATABASE_URL)
DB.extension(:implicit_subquery)
