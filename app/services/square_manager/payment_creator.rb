# frozen_string_literal: true

module SquareManager
  class PaymentCreator < BaseService
    attr_reader :nonce, :amount, :email, :note, :location_id

    def initialize(params)
      @nonce = params[:nonce]
      @amount = params[:amount]
      @email = params[:email]
      @note = params[:note]
      @location_id = params[:location_id]
    end

    def call
      client = Square::Client.new(
        access_token: ENV['SQUARE_ACCESS_TOKEN'],
        environment: Rails.env.production? ? 'production' : 'sandbox'
      )
      client.payments.create_payment(body: create_payment_body)
    end

    private

    def create_payment_body
      {
        source_id: nonce,
        idempotency_key: SecureRandom.uuid,
        amount_money: { amount: amount, currency: 'USD' },
        buyer_email_address: email,
        note: note,
        location_id: location_id
      }
    end
  end
end