module Admin::RolesHelper
  def role_description(role)
    Role::DESCRIPTIONS.fetch(role.name, "Role kustom untuk pengguna aplikasi.")
  end

  def role_scope_label(role)
    role.global? ? "Global" : "#{role.resource_type} ##{role.resource_id}"
  end
end
