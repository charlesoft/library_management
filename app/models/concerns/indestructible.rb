module Indestructible
  extend ActiveSupport::Concern

  included do
    default_scope { where(deleted: false) }
  end

  def delete!
    self.update_columns(deleted: true, deleted_at: Time.current)
  end
end


