class JwtDenylist < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist
  include Indestructible

  self.table_name = 'jwt_denylists'
end
