require 'mcrypt'

class Blowfish
  def initialize(key)
    @key = key
    @crypto = Mcrypt.new(:blowfish, :ecb, key)
    @crypto.padding = :zeros
  end

  def padding=(padding)
    @crypto = padding
  end

  def encrypt(data, encoding_type = 'utf-8')
    @crypto.encrypt(data).force_encoding(encoding_type)
  end

  def decrypt(data)
    @crypto.decrypt(data)
  end
end
