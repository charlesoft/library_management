# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_10_05_231239) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "book_borrowings", force: :cascade do |t|
    t.bigint "book_id", null: false
    t.bigint "user_id", null: false
    t.date "borrowing_date", null: false
    t.date "due_date", null: false
    t.date "returned_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "deleted_at"
    t.index ["book_id", "user_id"], name: "index_book_borrowings_on_book_user_active", unique: true, where: "(returned_date IS NULL)"
    t.index ["book_id"], name: "index_book_borrowings_on_book_id"
    t.index ["user_id"], name: "index_book_borrowings_on_user_id"
  end

  create_table "books", force: :cascade do |t|
    t.string "title", null: false
    t.string "author", null: false
    t.string "genre", null: false
    t.string "isbn", null: false
    t.integer "total_copies", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "available", default: true, null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "deleted_at"
    t.index ["author"], name: "index_books_on_author"
    t.index ["genre"], name: "index_books_on_genre"
    t.index ["isbn"], name: "index_books_on_isbn", unique: true
    t.index ["title"], name: "index_books_on_title", unique: true
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti"
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "deleted_at"
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
  end

  create_table "user_roles", force: :cascade do |t|
    t.string "name", default: "member", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "deleted_at"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_role_id", null: false
    t.boolean "deleted", default: false, null: false
    t.datetime "deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["user_role_id"], name: "index_users_on_user_role_id"
  end

  add_foreign_key "book_borrowings", "books"
  add_foreign_key "book_borrowings", "users"
  add_foreign_key "users", "user_roles"
end
