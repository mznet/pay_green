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

    STATUS_WAITING = "WAITING"
    STATUS_PENDING = "PENDING"
    STATUS_EXPIRED = 'EXPIRED'
    STATUS_PENDING_EXEC = "PENDING_EXEC"
    STATUS_WAITING_EXEC = "WAITING_EXEC"
    STATUS_CANCELLING = "CANCELLED"
    STATUS_REFUSED = "REFUSED"
    STATUS_SUCCESSED = "SUCCESSED"
    STATUS_RESETED = "RESETED"
    STATUS_REFUNDED = "REFUNDED"
    STATUS_FAILED = "FAILED"

    RECURRING_DAILY = 10
    RECURRING_WEEKLY = 20
    RECURRING_SEMI_MONTHLY = 30
    RECURRING_MONTHLY = 40
    RECURRING_BIMONTHLY = 50
    RECURRING_QUARTERLY = 60
    RECURRING_SEMI_ANNUAL = 70
    RECURRING_ANNUAL = 80
    RECURRING_BIANNUAL = 90


    def initialize(encrypt_key, root_url = nil)
      @key = encrypt_key
      @host = "#{root_url}/paiement/new/" unless root_url.nil?
      @data = {}
      @host = 'https://paygreen.fr/paiement/new/'
    end

    def private_key(encrypt_key)
      encrypt_key = encrypt_key.to_s if encrypt_key.is_a? Integer
      @key = encrypt_key
    end

    def set_token(shop_token)
      token_with_time = "#{DateTime.now.to_time.to_i}:#{shop_token}"
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
      Base64.strict_encode64(encrypted_block).strip
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

    def transaction(transaction_id, amount, currency = CURRENCY_EUR)
      @transaction_id = transaction_id
      @mode = MODE_CASH
      @amount = amount
      @currency = currency
      self
    end

    # Immediate Payment
    def immediate_paiement(transaction_id, amount, currency = CURRENCY_EUR)
      transaction(transaction_id, amount, currency)
    end

    def card_print
      @mode = MODE_TOKENIZE
    end

    def additional_transaction(amount)
      if @mode == MODE_RECURRING
        @additional_transaction = amount
      else
        raise 'This function can only be used with a reccurence transaction'
      end

      self
    end

    def subscribtion_payment(recurring_mode = nil, due_count = nil, transaction_day - 1, start_at = nil)
      @mode = MODE_RECURRING
      unless recurring_mode.nil?
        @recurring_mode = recurring_mode
        @recurring_due_count = due_count
        @recurring_transaction_day = transaction_day
        @recurring_start_at = start_at
      end

      self
    end

    def subscription_first_amount(first_amount, first_amount_date = nil)
      @recurring_first_amount = first_amount
      @recurring_first_amount_date = first_amount_date
    end

    def x_time_payment(nb_payment, report_payment = nil)
      amount = @amount
      currency = @currency

      if nb_payment > 1
        occurence_amount = (amount / nb_payment).floor
        first_amount = amount - ( occurence_amount * (nb_payment - 1))

        date_report_payment = report_payment.nil? ? nil : Time.parse(report_payment).to_i

        subscribtion_payment(
          RECURRING_MONTLY,
          nb_payment,
          Time.new.day,
          date_report_payment
        )

        subscribtion_payment(first_amount) if occurence_amount != first_amount
      end
    end

    def shipping_to(last_name, first_name, address, address2, company, zip_code, city, country = 'FR')
      @shipping_to_last_name = last_name.nil? ? @customer_last_name : last_name
      @shipping_to_first_name = first_name.nil? ? @customer_first_name : first_name
      @shipping_to_address = address
      @shipping_to_address2 = address2
      @shipping_to_company = company
      @shipping_to_zipcode = zip_code
      @shipping_to_city = city
      @shipping_to_country = country
    end

    def push_cart_item(id_item, label, qt, price_ttc, price_ht = nil, vat_value = nil, category_code = nil)
      if @data['cart_items'].nil?
        @data['cart_items'] = {}
      end

      @data['cart_items'] = {
        item_code: id_item,
        label: label,
        quantity: qt,
        price_ht: price_ht,
        price_ttc: price_ttc,
        vat: vat_value,
        category_code: category_code
      }
    end
  end
end
