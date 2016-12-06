require 'pay_green/version'
require 'base64'
require 'json'
require 'blowfish'

module PayGreen
  class API
    attr_accessor :data
    attr_accessor :customer_id
    attr_accessor :customer_first_name
    attr_accessor :customer_last_name
    attr_accessor :customer_email
    attr_accessor :customer_country
    attr_accessor :transaction_id
    attr_accessor :mode
    attr_accessor :amount
    attr_accessor :currency
    attr_accessor :key

    CURRENCY_EUR = 'EUR'

    MODE_CASH = 'CASH'
    MODE_RECURRING = 'RECURRING'
    MODE_TOKENIZE = 'TOKENIZE'

    STATUS_WAITING = "WAITING";
    STATUS_PENDING = "PENDING";
    STATUS_EXPIRED = 'EXPIRED';
    STATUS_PENDING_EXEC = "PENDING_EXEC";
    STATUS_WAITING_EXEC = "WAITING_EXEC";
    STATUS_CANCELLING = "CANCELLED";
    STATUS_REFUSED = "REFUSED";
    STATUS_SUCCESSED = "SUCCESSED";
    STATUS_RESETED = "RESETED";
    STATUS_REFUNDED = "REFUNDED";
    STATUS_FAILED = "FAILED";

    def initialize(encrypt_key, root_url = nil)
      @key = encrypt_key
      @host = "#{root_url}/paiement/new/" unless root_url.nil?
      @data = {}
      @host = 'https://paygreen.fr/paiement/new/'
    end

    def private_key(encrypt_key)
      @key = encrypt_key
    end

    def set_token(shop_token)
      token_with_time = "#{DateTime.current.to_i}:#{shop_token}"
      @token = Base64.strict_encode64(token_with_time)
    end

    def parse_token(token)
      @token = token
      Base64.decode64(token).split(':')
    end

    def customer(id, first_name, last_name, email, country = 'FR')
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

      attributes.map do |x|
        @data[x.to_s.delete('@')] = instance_variable_get x.to_s
      end

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

    def set(name, value)
      @data[name] = value
    end

    def get(name)
      @data[name]
    end

    def to_array
      @data
    end

    def merge_data(data)
      @data.merge!(data)
    end

    def is_accepted
      return -1 unless @data.key('result')
      @data['result']['status'] == STATUS_SUCCESSED
    end

    # Immediate Payment
    def immediate_paiement(transaction_id, amount, currency = CURRENCY_EUR)
      transaction(transaction_id, amount, currency)
    end

    def card_print
      @mode = MODE_TOKENIZE
    end
  end
end
