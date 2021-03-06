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

ActiveRecord::Schema.define(version: 20171025201751) do

  create_table "achivments", force: :cascade do |t|
    t.string  "title"
    t.string  "icon"
    t.string  "description"
    t.float   "percentage",  default: 0.0
    t.boolean "public",      default: true
  end

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
    t.integer  "current_sadness"
    t.text     "raw"
  end

  create_table "companies", force: :cascade do |t|
    t.string  "title",               null: false
    t.integer "score",   default: 0
    t.integer "sadness"
  end

  create_table "divisions", force: :cascade do |t|
    t.string  "title",                                                                                      null: false
    t.string  "telegram_id"
    t.integer "company_id"
    t.boolean "autopin",        default: false
    t.string  "message",        default: "15 минут до взлома, не забудьте поесть и слить деньги в акции"
    t.boolean "autopin_nighty", default: false
    t.string  "nighty_message", default: "Проверьте автосон, ловите биржевиков, приходите завтра на взлом"
  end

  create_table "monsters", force: :cascade do |t|
    t.string  "title"
    t.integer "hp2"
    t.integer "hp3"
    t.integer "hp4"
    t.integer "hp5"
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
    t.string  "md5"
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

  create_table "user_achivments", force: :cascade do |t|
    t.integer "achivment_id"
    t.integer "user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string   "game_name",                                           null: false
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
    t.datetime "last_remind_at",      default: '2017-10-05 19:39:25'
    t.integer  "motivation"
    t.string   "halloween_status",    default: "inactive"
    t.datetime "star_journey_at"
  end

end
