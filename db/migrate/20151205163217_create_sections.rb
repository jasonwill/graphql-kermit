class CreateSections < ActiveRecord::Migration
  def change
    create_table "schedules", force: :cascade do |t|
      t.string   "days"
      t.datetime "starts_at"
      t.datetime "ends_at"
      t.string   "room"
      t.integer  "section_id"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "building_id"
      t.datetime "session_start_time"
      t.datetime "session_end_time"
    end

    add_index "schedules", ["section_id"], name: "index_schedules_on_section_id", using: :btree
    add_index "schedules", ["starts_at"], name: "index_schedules_on_starts_at", using: :btree

    create_table "sections", force: :cascade do |t|
      t.integer  "year"
      t.string   "term",              limit: 255, default: ""
      t.string   "course_code",       limit: 255
      t.string   "section_code",      limit: 255, default: ""
      t.string   "long_name",         limit: 255, default: ""
      t.string   "short_name",        limit: 255, default: ""
      t.text     "description"
      t.string   "category",          limit: 255
      t.string   "department",        limit: 255, default: ""
      t.string   "program",           limit: 255, default: ""
      t.string   "credit_type",       limit: 255, default: ""
      t.float    "credits"
      t.integer  "min_participants"
      t.integer  "max_participants"
      t.integer  "adds"
      t.integer  "drops"
      t.integer  "waitlist"
      t.string   "enrollment_status", limit: 255, default: "open"
      t.integer  "ext_id"
      t.string   "ext_creator_ref",   limit: 255, default: ""
      t.integer  "imported_by"
      t.string   "event_type",        limit: 255, default: ""
      t.string   "uuid",              limit: 255, default: ""
      t.string   "event_status",      limit: 255, default: ""
      t.string   "department_code",   limit: 255, default: ""
      t.datetime "imported_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "hr_site_id"
    end

    add_index "sections", ["hr_site_id"], name: "index_sections_on_hr_site_id", using: :btree

  end
end
