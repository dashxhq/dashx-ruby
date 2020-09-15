require 'httparty'

module DashX
  class Client
    include HTTParty
    base_uri 'https://api.dashx.com/v1'

    def initialize(config)
      @config = config

      self.class.base_uri(config[:base_uri])
      self.class.headers({
        'X-Public-Key' => config[:public_key],
        'X-Private-Key' => config[:private_key]
      })
    end

    def make_http_request(uri, body)
      self.class.send(:post, "/#{uri}", { body: body })
    end

    def identify(uid, options = {})
      symbolize_keys! options

      if uid.is_a? String
        params = { uid: uid }.merge(options)
      else
        params = { anonymous_uid: SecureRandom.uuid }.merge(options)
      end

      make_http_request('identify', params)
    end

    def track(event, uid, data = nil)
      if !data.nil? then symbolize_keys! data end

      make_http_request('track', { event: event, uid: uid, data: data })
    end

    def symbolize_keys!(hash)
      new_hash = hash.each_with_object({}) do |(k, v), memo|
        memo[k.to_sym] = v
      end

      hash.replace(new_hash)
    end
  end
end
