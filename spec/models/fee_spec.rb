# frozen_string_literal: true

# == Schema Information
#
# Table name: fees
#
#  id                  :bigint           not null, primary key
#  active              :boolean          default(TRUE)
#  covered_by_customer :boolean
#  flat_cost           :decimal(8, 2)    default(0.0)
#  multiplier          :decimal(, )      default(0.0)
#  seller_id           :bigint           not null
#
# Indexes
#
#  index_fees_on_seller_id  (seller_id)
#
require 'rails_helper'

RSpec.describe Fee, type: :model do
  # Association test
  it { should belong_to(:seller) }
end
