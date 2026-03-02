# ===============================
# CLEAN DATABASE
# ===============================
AssetAssignment.destroy_all
Asset.destroy_all
User.destroy_all

puts "Seeding database..."

# ===============================
# CREATE ADMIN USER
# ===============================
admin = User.create!(
  name: "Ritesh Admin",
  email: "admin@company.com",
  role: "admin",
  emp_id: "EMP0001",
  joining_date: Date.today,
  phone: "9999999999",
  gmail: "admin@gmail.com",
  password: "admin123",
  password_confirmation: "admin123"
)

puts "Admin created"

# ===============================
# CREATE EMPLOYEES
# ===============================
employees = [
  { name: "Ajay Kumar", email: "ajay@company.com", emp_id: "EMP1001" },
  { name: "Ramesh Singh", email: "ramesh@company.com", emp_id: "EMP1002" },
  { name: "Priya Sharma", email: "priya@company.com", emp_id: "EMP1003" }
]

employees.each do |emp|
  User.create!(
    name: emp[:name],
    email: emp[:email],
    role: "user",
    emp_id: emp[:emp_id],
    joining_date: Date.today - rand(100),
    phone: "8888888888",
    gmail: emp[:email],
    password: "password123",
    password_confirmation: "password123"
  )
end

puts "Employees created"

# ===============================
# CREATE ASSETS
# ===============================
assets = [
  { category: "Laptop", brand: "Dell", model: "Latitude 5420", serial: "ABC123XYZ", location: "Noida" },
  { category: "Laptop", brand: "HP", model: "ProBook 440", serial: "HP445566", location: "Delhi" },
  { category: "Server", brand: "IBM", model: "XSeries", serial: "SRV12345", location: "Kochi" },
  { category: "Router", brand: "TP-Link", model: "AX1800", serial: "RTR001", location: "Noida" }
]

assets.each_with_index do |a, i|
  Asset.create!(
    asset_tag: "AST-000#{i+1}",
    asset_category: a[:category],
    brand: a[:brand],
    model_id: a[:model],
    serial_number: a[:serial],
    purchase_date: Date.today - 365,
    purchase_cost: rand(20000..80000),
    location: a[:location],
    asset_status: "Working"
  )
end

puts "Assets created"

# ===============================
# CREATE ASSIGNMENT HISTORY
# ===============================
asset1 = Asset.first
user1 = User.find_by(emp_id: "EMP1001")
user2 = User.find_by(emp_id: "EMP1002")

# Old closed assignment
AssetAssignment.create!(
  asset: asset1,
  assigned_to: user1.emp_id,
  assigned_from_date: Date.today - 30,
  assigned_to_date: Date.today - 10,
  location: "Noida"
)

# Current active assignment
current = AssetAssignment.create!(
  asset: asset1,
  assigned_to: user2.emp_id,
  assigned_from_date: Date.today - 5,
  location: "Delhi"
)

# Sync snapshot
asset1.update!(
  assigned_to: current.assigned_to,
  assigned_date: current.assigned_from_date,
  location: current.location
)

puts "Assignment history created"

puts "Seeding completed successfully 🚀"
