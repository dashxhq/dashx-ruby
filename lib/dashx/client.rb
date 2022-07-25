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
            success
        }
      }
    '

    SAVE_CONTACTS_REQUEST = 'mutation SaveContacts($input: SaveContactsInput!) {
        saveContacts(input: $input) {
            contacts {
              id
            }
        }
      }
    '

    FETCH_ITEM_REQUEST = 'query FetchItem($input: FetchItemInput) {
        fetchItem(input: $input) {
          id
          installationId
          name
          identifier
          description
          createdAt
          updatedAt
          pricings {
            id
            kind
            amount
            originalAmount
            isRecurring
            recurringInterval
            recurringIntervalUnit
            appleProductIdentifier
            googleProductIdentifier
            currencyCode
            createdAt
            updatedAt
          }
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

    def deliver(urn, options)
      contentTypeIdentifier, contentIdentifier = urn.split(/\//, 2)

      options ||= {}

      symbolize_keys! options

      options[:content] ||= {}

      [:to, :cc, :bcc].each do |kind|
        value = options.delete(kind)

        options[:content][kind] ||= value if value
        options[:content][kind] = wrap_array(options[:content][kind]) if options[:content][kind]
      end

      params = {
        contentTypeIdentifier: contentTypeIdentifier,
        contentIdentifier: contentIdentifier
      }.merge(options)

      make_graphql_request(CREATE_DELIVERY_REQUEST, params)
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

      make_graphql_request(TRACK_EVENT_REQUEST, { event: event, accountUid: uid, data: data })
    end

    def generate_identity_token(uid, options = {})
      check_presence!(uid, 'uid')
      symbolize_keys! options

      kind = options[:kind] || 'regular'
      plain_text = "v1;#{kind};#{uid}"

      cipher = OpenSSL::Cipher::AES.new(256, :GCM).encrypt
      cipher.key = @config.private_key
      nonce = cipher.random_iv
      cipher.iv = nonce
      encrypted = cipher.update(plain_text) + cipher.final
      encrypted_token = "#{nonce}#{encrypted}#{cipher.auth_tag}"
      Base64.urlsafe_encode64(encrypted_token)
    end

    def save_contacts(uid, contacts = [])
      contacts.each(&:symbolize_keys!)
      make_graphql_request(SAVE_CONTACTS_REQUEST, { uid: uid, contacts: contacts })
    end

    def fetch_item(identifier)
      make_graphql_request(FETCH_ITEM_REQUEST, { identifier: identifier })
    end

    private

    def make_graphql_request(request, params)
      body = { query: request, variables: { input: params } }.to_json
      response = self.class.post('/graphql', { body: body })
      raise "Request Failed: #{response}" if !response.success? || response.parsed_response.nil? || !response.parsed_response['errors'].nil?
      response
    end

    def symbolize_keys!(hash)
      new_hash = hash.each_with_object({}) do |(k, v), memo|
        memo[k.to_sym] = v
      end

      hash.replace(new_hash)
    end

    def wrap_array(obj)
      obj.is_a?(Array) ? obj : [obj]
    end

    def check_presence!(obj, name = obj)
      raise ArgumentError, "#{name} cannot be blank." if obj.nil? || (obj.is_a?(String) && obj.empty?)
    end
  end
end
