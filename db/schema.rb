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

ActiveRecord::Schema[8.1].define(version: 2026_02_27_112617) do
  create_table "asset_assignments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "asset_id", null: false
    t.date "assigned_from_date"
    t.string "assigned_to"
    t.date "assigned_to_date"
    t.datetime "created_at", null: false
    t.string "location"
    t.datetime "updated_at", null: false
    t.index ["asset_id"], name: "index_asset_assignments_on_asset_id"
    t.index ["assigned_to_date"], name: "index_asset_assignments_on_assigned_to_date"
  end

  create_table "assets", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "asset_category"
    t.string "asset_status"
    t.string "asset_tag"
    t.date "assigned_date"
    t.string "assigned_to"
    t.string "brand"
    t.string "configuration"
    t.string "cpu_core"
    t.datetime "created_at", null: false
    t.string "device_type"
    t.string "location"
    t.string "model_id"
    t.string "operating_system"
    t.integer "purchase_cost"
    t.date "purchase_date"
    t.integer "repairing_cost"
    t.date "repairing_date"
    t.string "serial_number"
    t.datetime "updated_at", null: false
    t.date "warranty_expiry_date"
    t.integer "warranty_years"
    t.index ["asset_category"], name: "index_assets_on_asset_category"
    t.index ["asset_status"], name: "index_assets_on_asset_status"
    t.index ["asset_tag"], name: "index_assets_on_asset_tag", unique: true
    t.index ["location"], name: "index_assets_on_location"
    t.index ["serial_number"], name: "index_assets_on_serial_number", unique: true
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "emp_id"
    t.string "gmail"
    t.date "joining_date"
    t.string "name"
    t.string "password_digest"
    t.string "phone"
    t.string "role"
    t.datetime "updated_at", null: false
    t.index ["emp_id"], name: "index_users_on_emp_id", unique: true
  end

  add_foreign_key "asset_assignments", "assets"
end
