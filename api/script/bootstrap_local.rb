# frozen_string_literal: true

email = ENV.fetch('LOCAL_ADMIN_EMAIL', 'admin@test-corp.local')
password = ENV.fetch('LOCAL_ADMIN_PASSWORD', 'password123!')

user = User.find_or_initialize_by(email: email)
user.role = 'admin'
user.password = password
user.password_confirmation = password

if user.new_record? || user.changed?
  user.save!
  puts "Local admin ready: #{email}"
else
  puts "Local admin already present: #{email}"
end
