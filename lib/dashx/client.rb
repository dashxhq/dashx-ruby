require 'httparty'

module DashX
  class Client
    include HTTParty
    base_uri 'https://api.dashx.com'

    CREATE_DELIVERY_REQUEST = 'mutation CreateDelivery($input: CreateDeliveryInput!) {
        createDelivery(input: $input) {
            id
        }
      }
    '

    IDENTIFY_ACCOUNT_REQUEST = 'mutation IdentifyAccount($input: IdentifyAccountInput!) {
        identifyAccount(input: $input) {
            id
        }
      }
    '

    TRACK_EVENT_REQUEST = 'mutation TrackEvent($input: TrackEventInput!) {
        trackEvent(input: $input) {
            id
        }
      }
    '

    def initialize(config)
      @config = config

      self.class.base_uri(config.base_uri)

      headers = {
        'X-Public-Key' => config.public_key,
        'X-Private-Key' => config.private_key,
      }

      if !config.target_environment.nil?
        headers['X-Target-Environment'] = config.target_environment
      end

      if !config.target_installation.nil?
        headers['X-Target-Installation'] = config.target_installation
      end

      self.class.headers(headers)
    end        

    def deliver(urn, parcel)
      options = if urn.is_a?(String) && parcel != nil
                  symbolize_keys! parcel
                  check_presence!(parcel[:to], 'Recipient (:to)')

                  contentTypeIdentifier, contentIdentifier = urn.split(/\//, 2)

                  {
                    contentTypeIdentifier: contentTypeIdentifier, 
                    contentIdentifier: contentIdentifier,
                    attachments: [],
                    cc: [],
                    bcc: [],
                  }.merge(parcel)
                else
                  symbolize_keys! urn
                  check_presence!(urn[:from], 'Sender (:from)')

                  { attachments: [], cc: [], bcc: [] }.merge(urn)
                end

      make_graphql_request(CREATE_DELIVERY_REQUEST, options)
    end

    def identify(uid, options)
      symbolize_keys! options

      params = if uid.is_a?(String) && options != nil
                 { uid: uid }.merge(options)
               else
                 { anonymousUid: SecureRandom.uuid }.merge(uid)
               end

      make_graphql_request(IDENTIFY_ACCOUNT_REQUEST, params)
    end

    def track(event, uid, data = nil)
      symbolize_keys! data unless data.nil?

      make_graphql_request(TRACK_EVENT_REQUEST, { event: event, uid: uid, data: data })
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

    def make_graphql_request(request, params)
      body = { query: request, variables: { input: params } }.to_json
      request = self.class.post('/graphql', { body: body })
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
