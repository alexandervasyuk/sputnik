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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130205055851) do

  create_table "characteristics", :force => true do |t|
    t.integer  "micropost_id"
    t.string   "characteristic"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "characteristics_users", :id => false, :force => true do |t|
    t.integer "characteristic_id"
    t.integer "user_id"
  end

  add_index "characteristics_users", ["characteristic_id", "user_id"], :name => "index_characteristics_users_on_characteristic_id_and_user_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "gcaches", :force => true do |t|
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "name"
    t.string   "address"
    t.decimal  "longitude"
    t.decimal  "latitude"
    t.string   "term"
    t.decimal  "search_latitude"
    t.decimal  "search_longitude"
    t.decimal  "rank"
  end

  add_index "gcaches", ["term", "name", "search_latitude", "search_longitude", "latitude", "longitude"], :name => "primary_index", :unique => true

  create_table "microposts", :force => true do |t|
    t.string   "content"
    t.integer  "user_id"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "location"
    t.datetime "time"
    t.text     "invitees"
    t.boolean  "content_proposal",  :default => true
    t.boolean  "time_proposal",     :default => true
    t.boolean  "location_proposal", :default => true
    t.decimal  "latitude"
    t.decimal  "longitude"
    t.datetime "end_time"
  end

  add_index "microposts", ["updated_at"], :name => "index_microposts_on_updated_at"
  add_index "microposts", ["user_id", "created_at"], :name => "index_microposts_on_user_id_and_created_at"

  create_table "notifications", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "read",       :default => false, :null => false
    t.string   "message"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.string   "link",       :default => ""
  end

  add_index "notifications", ["user_id"], :name => "index_notifications_on_user_id"

  create_table "participations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "micropost_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "participations", ["micropost_id"], :name => "index_participations_on_micropost_id"
  add_index "participations", ["user_id", "micropost_id"], :name => "index_participations_on_user_id_and_micropost_id", :unique => true
  add_index "participations", ["user_id"], :name => "index_participations_on_user_id"

  create_table "polls", :force => true do |t|
    t.integer  "micropost_id"
    t.string   "poll_type"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "question"
  end

  create_table "posts", :force => true do |t|
    t.integer  "user_id"
    t.integer  "micropost_id"
    t.string   "content"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
  end

  add_index "posts", ["micropost_id"], :name => "index_posts_on_micropost_id"
  add_index "posts", ["user_id"], :name => "index_posts_on_user_id"

  create_table "proposals", :force => true do |t|
    t.string   "content"
    t.string   "location"
    t.datetime "time"
    t.integer  "votes"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "poll_id"
    t.datetime "end_time"
  end

  create_table "proposals_users", :id => false, :force => true do |t|
    t.integer "proposal_id"
    t.integer "user_id"
  end

  add_index "proposals_users", ["proposal_id", "user_id"], :name => "index_proposals_users_on_proposal_id_and_user_id"

  create_table "relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "friend_status"
    t.boolean  "follow1"
    t.boolean  "follow2"
  end

  add_index "relationships", ["followed_id"], :name => "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id", "followed_id"], :name => "index_relationships_on_follower_id_and_followed_id", :unique => true
  add_index "relationships", ["follower_id"], :name => "index_relationships_on_follower_id"

  create_table "user_gcaches", :force => true do |t|
    t.integer  "gcach_id"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "user_gcaches", ["gcach_id"], :name => "index_user_gcaches_on_gcach_id"
  add_index "user_gcaches", ["user_id", "gcach_id"], :name => "index_user_gcaches_on_user_id_and_gcach_id", :unique => true
  add_index "user_gcaches", ["user_id"], :name => "index_user_gcaches_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.string   "password_digest"
    t.string   "remember_token"
    t.boolean  "admin",                  :default => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.boolean  "temp",                   :default => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
