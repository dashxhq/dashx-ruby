require 'httparty'

module DashX
  class Client
    include HTTParty

    def initialize(config)
      @config = config

      self.class.base_uri(config.base_uri || 'https://api.dashx.com/v1')
      self.class.headers({
        'X-Public-Key' => config.public_key,
        'X-Private-Key' => config.private_key
      })
    end

    def make_http_request(uri, body)
      send_request(:post, "/#{uri}", { body: body })
    end

    def identify(uid, options = {})
      symbolize_keys! options

      if uid.is_a? String
        params = { uid: uid }.merge(options)
      else
        params = { anonymous_uid: SecureRandom.uuid }.merge(options)

      make_http_request('identify', params)
    end

    def track(event, uid, data)
      symbolize_keys! data

      make_http_request('deliveries', { event: event, uid: uid, data: data })
    end
  end
end