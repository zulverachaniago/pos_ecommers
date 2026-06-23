after_create :assign_default_role

private

def assign_default_role
  self.add_role :admin if User.count == 1          # User pertama jadi admin
  self.add_role :cashier unless self.has_role?(:admin)
end