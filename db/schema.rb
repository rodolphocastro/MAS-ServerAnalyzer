# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150624232159) do

  create_table "data_files", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "top_logs", force: :cascade do |t|
    t.string   "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "top_file"
  end

  create_table "top_processes", force: :cascade do |t|
    t.string   "header"
    t.integer  "pid"
    t.string   "user"
    t.integer  "pr"
    t.integer  "ni"
    t.integer  "virt"
    t.integer  "res"
    t.string   "shr"
    t.string   "s"
    t.float    "cpu_usage"
    t.float    "mem_usage"
    t.float    "time_usage"
    t.string   "command"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
