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

ActiveRecord::Schema.define(version: 2019_08_03_155340) do

  create_table "contributions", force: :cascade do |t|
    t.string "image"
    t.integer "like"
    t.string "author"
    t.integer "mentor_id"
    t.index ["mentor_id"], name: "index_contributions_on_mentor_id"
  end

  create_table "mentors", force: :cascade do |t|
    t.string "name"
    t.string "image"
    t.boolean "wide"
  end

end
