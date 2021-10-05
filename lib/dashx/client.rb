require 'httparty'

module DashX
  class Client
    include HTTParty
    base_uri 'https://api.dashx.com'

    @@create_delivery_request = 'mutation CreateDelivery($input: CreateDeliveryInput!) {
        createDelivery(input: $input) {
            id
        }
      }
    '

    @@identify_account_request = 'mutation IdentifyAccount($input: IdentifyAccountInput!) {
        identifyAccount(input: $input) {
            id
        }
      }
    '

    @@track_event_request = 'mutation TrackEvent($input: TrackEventInput!) {
        trackEvent(input: $input) {
            id
        }
      }
    '

    def initialize(config)
      @config = config

      self.class.base_uri(config.base_uri)
      self.class.headers({
        'X-Public-Key' => config.public_key,
        'X-Private-Key' => config.private_key,
      }.merge(
        if config.target_installation != nil
          { 'X-Target-Installation' => config.target_installation }
        else
          {}
        end
      ).merge(
        if config.target_environment != nil
          { 'X-Target-Environment' => config.target_environment }
        else
          {}
        end
      ))
    end        
    
    def deliver(urn, parcel)
      options = if urn.is_a? String and parcel != nil
                  symbolize_keys! parcel
                  check_presence!(parcel[:to], 'Recipient')

                  contentTypeIdentifier, contentIdentifier = urn.split('/', 1)

                  {
                    contentTypeIdentifier: contentTypeIdentifier, 
                    contentIdentifier: contentIdentifier,
                    attachments: [],
                    cc: [],
                    bcc: [],
                  }.merge(parcel)
                else
                  symbolize_keys! urn
                  check_presence!(urn[:from], 'Sender')

                  { attachments: [], cc: [], bcc: [] }.merge(urn)
                end

      make_graphql_request(@@create_delivery_request, options)
    end

    def identify(uid, options)
      symbolize_keys! options

      params = if uid.is_a? String and options != nil
                 { uid: uid }.merge(options)
               else
                 { anonymousUid: SecureRandom.uuid }.merge(uid)
               end

      make_graphql_request(@@identify_account_request, params)
    end

    def track(event, uid, data = nil)
      symbolize_keys! data unless data.nil?

      make_graphql_request(@@track_event_request, { event: event, uid: uid, data: data })
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
      request = self.class.post("/graphql", { body: body })
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
