# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171125154549) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "controllers", force: :cascade do |t|
    t.string "Jobs"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "crono_jobs", id: :serial, force: :cascade do |t|
    t.string "job_id", null: false
    t.text "log"
    t.datetime "last_performed_at"
    t.boolean "healthy"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_id"], name: "index_crono_jobs_on_job_id", unique: true
  end

  create_table "jobs", force: :cascade do |t|
    t.string "heading"
    t.string "date_posted"
    t.string "slug"
    t.string "municipality_name"
    t.string "export_image_url"
    t.string "company_name"
    t.string "descr"
    t.string "latitude"
    t.string "longitude"
    t.string "area_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "sha"
  end

  create_table "jobs_users", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "job_id", null: false
    t.index ["job_id", "user_id"], name: "index_jobs_users_on_job_id_and_user_id"
    t.index ["user_id", "job_id"], name: "index_jobs_users_on_user_id_and_job_id"
  end

  create_table "matches", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "job_id"
    t.boolean "seen", default: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "messenger_id"
    t.string "city"
    t.string "preferences"
    t.datetime "last_update"
    t.boolean "require_city", default: true
    t.boolean "require_preference", default: true
    t.boolean "subscribed", default: false
  end

end
