# frozen_string_literal: true

class AddUserToCustomers < ActiveRecord::Migration[8.1]
  def up
    add_reference :customers, :user, null: true, foreign_key: true, index: { unique: true }

    backfill_customer_profiles
  end

  def down
    remove_reference :customers, :user, foreign_key: true
  end

  private

  def backfill_customer_profiles
    return unless column_exists?(:customers, :user_id)

    say_with_time "Menghubungkan user customer yang sudah ada ke profil pelanggan" do
      User.find_each do |user|
        next unless user.has_role?(:customer)
        next if Customer.exists?(user_id: user.id)

        Customer.create!(
          user_id: user.id,
          name: user.email.to_s.split("@").first.capitalize,
          customer_type: :retail,
          balance: 0
        )
      end
    end
  end
end
