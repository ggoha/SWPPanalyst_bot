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

ActiveRecord::Schema.define(version: 20170927220720) do

  create_table "admin_divisions", force: :cascade do |t|
    t.integer "division_id"
    t.integer "admin_id"
  end

  create_table "battles", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "score"
    t.integer  "summary_score"
    t.boolean  "result"
    t.datetime "at"
    t.integer  "money"
    t.float    "percent_score"
    t.string   "name"
  end

  create_table "companies", force: :cascade do |t|
    t.string  "title",               null: false
    t.integer "score",   default: 0
    t.integer "sadness"
  end

  create_table "divisions", force: :cascade do |t|
    t.string  "title",                                                                                 null: false
    t.string  "telegram_id"
    t.integer "company_id"
    t.boolean "autopin",     default: false
    t.string  "message",     default: "15 минут до взлома, не забудьте поесть и слить деньги в акции"
  end

  create_table "reports", force: :cascade do |t|
    t.integer "user_id"
    t.integer "broked_company_id"
    t.integer "battle_id"
    t.integer "kill"
    t.integer "money"
    t.integer "score"
    t.boolean "active"
    t.float   "buff"
  end

  create_table "stocks", force: :cascade do |t|
    t.integer  "company_id"
    t.integer  "price"
    t.datetime "at"
    t.string   "name"
  end

  create_table "task_records", id: false, force: :cascade do |t|
    t.string "version", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "game_name",                            null: false
    t.string   "telegram_id"
    t.integer  "company_id"
    t.string   "username"
    t.integer  "division_id"
    t.integer  "practice"
    t.integer  "theory"
    t.integer  "cunning"
    t.integer  "wisdom"
    t.integer  "rage",                default: 0
    t.integer  "level"
    t.integer  "stars"
    t.integer  "endurance"
    t.integer  "experience"
    t.string   "type",                default: "User"
    t.integer  "mvp",                 default: 0
    t.datetime "profile_update_at"
    t.datetime "endurance_update_at"
  end

end
