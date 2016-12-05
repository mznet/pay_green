require 'pay_green/version'
require 'base64'
require 'json'
require 'blowfish'

module PayGreen
  class API
    CURRENCY_EUR = 'EUR'
    MODE_CASH = 'CASH'

    def initialize(encrypt_key, root_url = nil)
      @key = encrypt_key
      @host = "#{root_url}/paiement/new/" unless root_url.nil?
      @data = {}
      @host = 'https://paygreen.fr/paiement/new/'
    end

    def set_token(shop_token)
      token_with_time = "#{DateTime.current.to_i}:#{shop_token}"
      @token = Base64.strict_encode64(token_with_time)
    end

    def customer(id, last_name, first_name, email, country = "FR")
      @customer_id = id
      @customer_last_name = last_name
      @customer_first_name = first_name
      @customer_email = email
      @customer_country = country
      self
    end

    def transaction(transaction_id, amount, currency = CURRENCY_EUR)
      @transaction_id = transaction_id
      @mode = MODE_CASH
      @amount = amount
      @currency = currency
      self
    end

    def returned_url(returned, notification, cancelled = nil)
      @return_url = returned
      @return_callback_url = notification
      @return_cancel_url = cancelled.nil? ? returned : cancelled
    end

    def get_action_form
      "#{@host}#{@token}"
    end

    def generate_data
      attributes = instance_variables
      attributes.delete(:@key)
      attributes.delete(:@data)
      attributes.delete(:@host)
      attributes.delete(:@token)

      attributes.map { |x| @data[x.to_s.delete('@')] = instance_variable_get x.to_s }
      text = JSON.generate(@data).encode('utf-8')
      blowfish = ::Blowfish.new(@key)
      encrypted_block = blowfish.encrypt(text)
      Base64.encode64(encrypted_block).strip
    end

    def parse_data(post)
      blowfish = ::Blowfish.new(@key)
      text = blowfish.decrypt(Base64.decode64(post)).strip
      @data = JSON.parse(text)
    end
  end
end


