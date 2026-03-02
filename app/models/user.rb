# app/models/user.rb
class User < ApplicationRecord
  has_secure_password   # enables password & password_confirmation

  ROLES = %w[admin user]

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :emp_id, presence: true, uniqueness: true
  validates :role, inclusion: { in: ROLES }

  validates :phone, length: { is: 10 }, allow_blank: true
end
