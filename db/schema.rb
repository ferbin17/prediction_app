# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_29_014155) do

  create_table "active_storage_attachments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "fixtures", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "game_week_id"
    t.boolean "finished", default: false
    t.datetime "kickoff_time"
    t.bigint "kickoff_time_epoch"
    t.boolean "started", default: false
    t.integer "away_team_id"
    t.integer "away_team_score", default: 0
    t.integer "home_team_id"
    t.integer "home_team_score", default: 0
    t.integer "slug"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "game_weeks", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name"
    t.datetime "deadline_time"
    t.bigint "deadline_time_epoch"
    t.boolean "finished", default: false
    t.boolean "is_previous", default: false
    t.boolean "is_current", default: false
    t.boolean "is_next", default: false
    t.integer "league_id"
    t.integer "slug"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "gw_score_calculated", default: false
  end

  create_table "league_tables", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "league_id"
    t.integer "team_id"
    t.integer "matches"
    t.integer "points"
    t.integer "wins"
    t.integer "draws"
    t.integer "lose"
    t.integer "goals_s"
    t.integer "goals_a"
    t.integer "goals_d"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "leagues", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.integer "no_of_teams"
    t.integer "slug"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "prediction_scores", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "fixture_id"
    t.string "scoreline"
    t.integer "winning_team_id"
    t.integer "prediction_id"
    t.boolean "score_calulated"
    t.float "calculated_score"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "prediction_tables", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "user_id"
    t.float "current_score"
    t.float "last_gw_score"
    t.integer "total_gw_predicted"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "total_gw_score_calculated", default: 0
  end

  create_table "predictions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "user_id"
    t.integer "game_week_id"
    t.boolean "gw_score_calulated", default: false
    t.float "calculated_gw_score"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "teams", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name"
    t.string "short_name"
    t.integer "league_id"
    t.integer "slug"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "username"
    t.string "email_id"
    t.string "password_salt"
    t.string "hashed_password"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.integer "failed_attempts", default: 0
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "phone_no"
    t.boolean "is_admin", default: false
    t.boolean "is_active", default: true
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
end
