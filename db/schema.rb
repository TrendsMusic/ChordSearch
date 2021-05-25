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

ActiveRecord::Schema.define(version: 2021_05_23_171939) do

  create_table "chords", charset: "utf8", force: :cascade do |t|
    t.string "section_numbar"
    t.string "content"
    t.bigint "song_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "key"
    t.index ["song_id"], name: "index_chords_on_song_id"
  end

  create_table "fields", charset: "utf8", force: :cascade do |t|
    t.string "part1"
    t.string "part2"
    t.string "part3"
    t.string "part4"
    t.bigint "chord_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "part5"
    t.index ["chord_id"], name: "index_fields_on_chord_id"
  end

  create_table "songs", charset: "utf8", force: :cascade do |t|
    t.string "title"
    t.string "artist"
    t.string "genre"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_songs_on_user_id"
  end

  create_table "users", charset: "utf8", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "chords", "songs"
  add_foreign_key "fields", "chords"
  add_foreign_key "songs", "users"
end
