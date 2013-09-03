class LegacyBacker < ActiveRecord::Base
  include LegacyBase
  establish_connection "legacy"

  self.table_name = "backers"
  self.primary_key = "id"

  has_one :legacy_payment_detail, foreign_key: 'backer_id'

  # To use autogenerated ids uncomment below
  def dont_migrate_ids
    false
  end

  def migrate_where
    {id: self.id}
  end

  def map
    {
      project_id: self.project_id,
      user_id: self.user_id,
      reward_id: self.reward_id,
      value: self.value,
      confirmed_at: self.confirmed_at,
      created_at: self.created_at,
      updated_at: self.updated_at,
      anonymous: self.anonymous,
      key: self.key,
      credits: self.credits,
      notified_finish: self.notified_finish,
      payment_method: self.payment_method,
      payment_token: self.payment_token,
      payment_id: self.payment_id,
      payer_name: payer_name,
      payer_email: payer_email,
      address_street: address_street,
      address_city: address_city,
      address_state: address_state,
      #payment_choice: text,
      payment_service_fee: payment_service_fee,
      state: get_state,
      short_note: self.user_note
    }
  end


  def get_state
    state = 'pending'

    state = 'confirmed' if self.confirmed

    state
  end

  def associate
    {
      payment_notifications: build_payment_notifications
    }
  end


  protected

  def build_payment_notifications
    return [ PaymentNotification.new(backer_id: self.id, extra_data: self.legacy_payment_detail.response_data)] if self.legacy_payment_detail and self.legacy_payment_detail.response_data.present?
    []
  end

  def address_street
    "#{self.legacy_payment_detail.street} #{self.legacy_payment_detail.street2}" if self.legacy_payment_detail
  end

  def address_city
    self.legacy_payment_detail.city if self.legacy_payment_detail
  end

  def address_state
    self.legacy_payment_detail.uf if self.legacy_payment_detail
  end

  def payer_email
    self.legacy_payment_detail.payer_email if self.legacy_payment_detail
  end

  def payer_name
    self.legacy_payment_detail.payer_name if self.legacy_payment_detail
  end

  def payment_service_fee
    self.legacy_payment_detail.service_tax_amount.to_f if self.legacy_payment_detail
  end

end
