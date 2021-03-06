# frozen_string_literal: true

# Creates donation and item with the corresponding payload
module WebhookManager
  class DonationCreator < BaseService
    attr_reader :seller_id, :project_id, :payment_intent, :amount

    def initialize(params)
      @seller_id = params[:seller_id]
      @project_id = params[:project_id]
      @payment_intent = params[:payment_intent]
      @amount = params[:amount]
    end

    def call
      ActiveRecord::Base.transaction do
        item = WebhookManager::ItemCreator.call({
                                                  item_type: :donation,
                                                  seller_id: seller_id,
                                                  project_id: project_id,
                                                  payment_intent: payment_intent
                                                })
        donation = DonationDetail.create!(
          item: item,
          amount: amount
        )

        donation
      end
    end
  end
end
