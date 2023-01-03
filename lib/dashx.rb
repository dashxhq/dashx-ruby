require 'dashx/version'
require 'dashx/config'
require 'dashx/client'

module DashX
  @clients = {}

  def self.configure(client_name = :default)
    yield config = DashX::Config.new

    @clients[client_name] = DashX::Client.new(config)
  end

  def self.deliver(urn, parcel)
    @clients[:default].deliver(urn, parcel)
  end

  def self.identify(uid, options)
    @clients[:default].identify(uid, options)
  end

  def self.track(event, uid, data)
    @clients[:default].track(event, uid, data)
  end

  def self.save_contacts(uid, contacts)
    @clients[:default].save_contacts(uid, contacts)
  end

  def self.fetch_item(identifier)
    @clients[:default].fetch_item(identifier)
  end
end
