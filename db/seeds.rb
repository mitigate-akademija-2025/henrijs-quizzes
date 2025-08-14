if User.where(admin: true).none?
  User.create!(
    username: "admin123",
    email: "admin123@example.com",
    password: "admin123@example.com",
    password_confirmation: "admin123@example.com",
    admin: true
  )
else
  puts "Admin user already exists."
end
