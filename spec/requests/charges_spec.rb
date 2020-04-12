require 'rails_helper'

RSpec.describe 'Charges API', type: :request do
  # Test suite for POST /charges
  describe 'POST /charges' do
    let(:email) { 'mrkrabs@thekrustykrab.com' }
    let(:params) { { email: email, line_items: line_items } }
    let(:seller_id) { 'shunfa-bakery' }
    let!(:seller) { create(:seller, seller_id: seller_id) }

    context 'with a gift card' do
      let(:line_items) do
        [
          {
            amount: 50,
            currency: 'usd',
            item_type: 'gift_card',
            quantity: 1,
            seller_id: seller_id
          }
        ]
      end

      before { post '/charges', params: params, as: :json }

      it 'returns Stripe PaymentIntent' do
        expect(json['id']).not_to be_empty
        expect(json['amount']).to eq(50)
        expect(json['currency']).to eq('usd')
        expect(json['receipt_email']).to eq(email)

        expect(PaymentIntent.find_by(
                 email: email,
                 line_items: line_items.to_json
        )).not_to be_nil
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'with line item with missing amount' do
      let(:line_items) do
        [
          {
            currency: 'usd',
            item_type: 'gift_card',
            quantity: 1,
            seller_id: seller_id
          }
        ]
      end

      before { post '/charges', params: params, as: :json }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/param is missing or the value is empty: amount/)
      end
    end

    context 'with line item with missing currency' do
      let(:line_items) do
        [
          {
            amount: 50,
            item_type: 'gift_card',
            quantity: 1,
            seller_id: seller_id
          }
        ]
      end

      before { post '/charges', params: params, as: :json }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/param is missing or the value is empty: currency/)
      end
    end

    context 'with line item with missing item_type' do
      let(:line_items) do
        [
          {
            amount: 50,
            currency: 'usd',
            quantity: 1,
            seller_id: seller_id
          }
        ]
      end

      before { post '/charges', params: params, as: :json }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/param is missing or the value is empty: item_type/)
      end
    end

    context 'with line item with missing quantity' do
      let(:line_items) do
        [
          {
            amount: 50,
            currency: 'usd',
            item_type: 'gift_card',
            seller_id: seller_id
          }
        ]
      end

      before { post '/charges', params: params, as: :json }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/param is missing or the value is empty: quantity/)
      end
    end

    context 'with line item with missing seller_id' do
      let(:line_items) do
        [
          {
            amount: 50,
            currency: 'usd',
            item_type: 'gift_card',
            quantity: 1
          }
        ]
      end

      before { post '/charges', params: params, as: :json }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/param is missing or the value is empty: seller_id/)
      end
    end

    context 'with an invalid name' do
      let(:line_items) do
        [
          {
            amount: 5000,
            currency: 'usd',
            item_type: 'Foobar',
            quantity: 1,
            seller_id: seller_id
          }
        ]
      end

      before { post '/charges', params: params, as: :json }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/line_item must be named `Gift Card` or `Donation`/)
      end
    end

    context 'with a negative amount' do
      let(:line_items) do
        [
          {
            amount: -1,
            currency: 'usd',
            item_type: 'gift_card',
            quantity: 1,
            seller_id: seller_id
          }
        ]
      end

      before { post '/charges', params: params, as: :json }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match('{"message":"Amount must be at least $0.50 usd"}')
      end
    end

    context 'with $.49 in the amount' do
      let(:line_items) do
        [
          {
            amount: 49,
            currency: 'usd',
            item_type: 'gift_card',
            quantity: 1,
            seller_id: seller_id
          }
        ]
      end

      before { post '/charges', params: params, as: :json }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match('{"message":"Amount must be at least $0.50 usd"}')
      end
    end

    context 'with string integer amount' do
      let(:line_items) do
        [
          {
            amount: '50',
            currency: 'usd',
            item_type: 'gift_card',
            quantity: 1,
            seller_id: seller_id
          }
        ]
      end

      before { post '/charges', params: params, as: :json }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match('line_item.amount must be an Integer')
      end
    end

    context 'with float amount' do
      let(:line_items) do
        [{
          amount: 50.5,
          currency: 'usd',
          item_type: 'gift_card',
          quantity: 1,
          seller_id: seller_id
        }]
      end

      before { post '/charges', params: params, as: :json }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match('line_item.amount must be an Integer')
      end
    end

    context 'with a gift card and donation' do
      let(:line_items) do
        [
          {
            amount: 5000,
            currency: 'usd',
            item_type: 'gift_card',
            quantity: 1,
            seller_id: seller_id
          },
          {
            amount: 3000,
            currency: 'usd',
            item_type: 'donation',
            quantity: 1,
            seller_id: seller_id
          }
        ]
      end

      before { post '/charges', params: params, as: :json }

      it 'returns Stripe PaymentIntent' do
        expect(json['id']).not_to be_empty
        expect(json['amount']).to eq(8000)
        expect(json['currency']).to eq('usd')
        expect(json['receipt_email']).to eq(email)

        expect(PaymentIntent.find_by(
                 email: email,
                 line_items: line_items.to_json
        )).not_to be_nil
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when the request is missing email' do
      before do
        post(
          '/charges',
          params: {
            line_items: [
              {
                amount: 50,
                currency: 'usd',
                item_type: 'gift_card',
                quantity: 1,
                seller_id: seller_id
              }
            ]
          },
          as: :json
        )
      end

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/param is missing or the value is empty: email/)
      end
    end

    context 'when the request is missing line_items' do
      before { post '/charges', params: { email: 'Foobar@foo.com' }, as: :json }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns a validation failure message' do
        expect(response.body)
          .to match(/param is missing or the value is empty: line_items/)
      end
    end
  end
end
