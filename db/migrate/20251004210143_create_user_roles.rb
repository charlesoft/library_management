class CreateUserRoles < ActiveRecord::Migration[7.1]
  def change
    create_table :user_roles do |t|
      t.string :name, null: false, default: 'member'

      t.timestamps
    end
  end
end
