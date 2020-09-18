require 'httparty'

module DashX
  class Client
    include HTTParty
    base_uri 'https://api.dashx.com/v1'

    def initialize(config)
      @config = config

      self.class.base_uri(config.base_uri)
      self.class.headers({
        'X-Public-Key' => config.public_key,
        'X-Private-Key' => config.private_key
      })
    end

    def deliver(parcel)
      symbolize_keys! parcel

      check_presence!(parcel[:to], 'Recipient')

      make_http_request('deliver', parcel)
    end

    def identify(uid, options = {})
      symbolize_keys! options

      params = if uid.is_a? String
                 { uid: uid }.merge(options)
               else
                 { anonymous_uid: SecureRandom.uuid }.merge(options)
               end

      make_http_request('identify', params)
    end

    def track(event, uid, data = nil)
      symbolize_keys! data unless data.nil?

      make_http_request('track', { event: event, uid: uid, data: data })
    end

    def generate_identity_token(uid)
      check_presence!(uid, 'uid')

      cipher = OpenSSL::Cipher::AES.new(256, :GCM).encrypt
      cipher.key = @config.private_key
      nonce = cipher.random_iv
      cipher.iv = nonce
      encrypted = cipher.update(uid) + cipher.final
      encrypted_token = "#{nonce}#{encrypted}#{cipher.auth_tag}"
      Base64.urlsafe_encode64(encrypted_token)
    end

    private

    def make_http_request(uri, body)
      self.class.send(:post, "/#{uri}", { body: body })
    end

    def symbolize_keys!(hash)
      new_hash = hash.each_with_object({}) do |(k, v), memo|
        memo[k.to_sym] = v
      end

      hash.replace(new_hash)
    end

    def check_presence!(obj, name = obj)
      raise ArgumentError, "#{name} cannot be blank." if obj.nil? || (obj.is_a?(String) && obj.empty?)
    end
  end
end
