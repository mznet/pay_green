require 'spec_helper'
require 'pry'

describe PayGreen do
  before do
    @pay_green = PayGreen::API.new('paygreen')
    @id = '123456'
    @first_name = 'Pay'
    @last_name = 'Green'
    @email = 'pay_green@paygreen.fr'
    @country_name = 'UK'

    @transaction_id = '654321'
    @mode = PayGreen::API::MODE_CASH
    @amount = 10
    @currency = PayGreen::API::CURRENCY_EUR

    @key = 'PAYGREEN'

    @returned_url = 'http://ma-boutique.fr/validation'
    @notification = 'http://ma-boutique.fr/notification'
  end

  describe '#private_key' do
    it 'assign encrypt key to key attribute' do
      @pay_green.private_key(@key)
      expect(@pay_green.key).to eq(@key)
    end
  end

  describe '#customer' do
    it 'set customer attributes' do
      @pay_green.customer(@id, @first_name, @last_name, @email, @country_name)
      expect(@pay_green.customer_id).to eq(@id)
      expect(@pay_green.customer_last_name).to eq(@last_name)
      expect(@pay_green.customer_first_name).to eq(@first_name)
      expect(@pay_green.customer_email).to eq(@email)
      expect(@pay_green.customer_country).to eq(@country_name)
    end
  end

  describe '#transaction' do
    it 'set transaction attributes' do
      @pay_green.transaction(@transaction_id, @amount, @currency)
      expect(@pay_green.transaction_id).to eq(@transaction_id)
      expect(@pay_green.mode).to eq(@mode)
      expect(@pay_green.amount).to eq(@amount)
      expect(@pay_green.currency).to eq(@currency)
    end
  end

  describe '#set' do
    it 'set name and value to data object' do
      key = :customer
      value = 'customer_data'

      @pay_green.set(key, value)
      expect(@pay_green.data[key]).to eq(value)
    end
  end

  describe '#get' do
    it 'set name and value to data object and retrieve the data object' do
      key = :customer
      value = 'customer_data'

      @pay_green.set(key, value)
      expect(@pay_green.get(key)).to eq(value)
    end
  end

  describe '#to_array' do
    it 'retreive data attribute' do
      expect(@pay_green.to_array).to eq(@pay_green.data)
    end
  end

  describe '#returned_url' do
    it 'set callback attributes' do
      @pay_green.returned_url(@returned_url, @notification)
    end
  end

  describe '#merge_data' do
    it 'merge an attribute with data atrribute' do
      @pay_green.merge_data(pay_green: 'pay_green')
      expect(@pay_green.data).to include(pay_green: 'pay_green')
    end
  end

  describe '#is_accepted' do
    context 'when result key is included in data attribute' do
      it 'status in data attribute and STATUS_SUCCESSED constant are same' do
      end

      it 'status in data attribute and STATUS_SUCCESSED constant are not same' do
      end
    end

    context 'when result key is not included in data attribute' do
      it 'data attribute doesn\'t have a result key' do
        expect(@pay_green.is_accepted).to eq(-1)
      end
    end

  end

  describe '#immediate_paiement' do
    it 'set transaction attributes using transaction method' do
      @pay_green.transaction(@transaction_id, @amount, @currency)
      expect(@pay_green.transaction_id).to eq(@transaction_id)
      expect(@pay_green.mode).to eq(@mode)
      expect(@pay_green.amount).to eq(@amount)
      expect(@pay_green.currency).to eq(@currency)
    end
  end

  describe '#card_print' do
    it 'retrieve MODE_TOKENIZE constant' do
      expect(@pay_green.card_print).to eq(PayGreen::API::MODE_TOKENIZE)
    end
  end
end
