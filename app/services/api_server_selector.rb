require "net/http"

class ApiServerSelector
  CONFIG_PATH = Rails.root.join("config/api_servers.yml")
  HEALTH_PATH = "/up".freeze
  HEALTH_CHECK_TTL = 30 # seconds

  @@index = 0
  @@mutex = Mutex.new
  @health_cache = {} # { url => { healthy: true/false, checked_at: Time } }

  class << self
    def servers
      @servers ||= YAML.load_file(CONFIG_PATH)["servers"]
    end

    def healthy_servers
      servers.select { |url| healthy?(url) }
    end

    def next
      @@mutex.synchronize do
        healthy = healthy_servers
        raise StandardError.new("No healthy API servers available") if healthy.empty?

        server = healthy[@@index % healthy.size]
        @@index = (@@index + 1) % healthy.size
        server
      end
    end

    private

    def healthy?(url)
      entry = @health_cache[url]
      now = Time.now

      # Recheck if stale or unknown
      if entry.nil? || (now - entry[:checked_at]) > HEALTH_CHECK_TTL
        healthy = perform_health_check(url)
        @health_cache[url] = { healthy: healthy, checked_at: now }
      end

      @health_cache[url][:healthy]
    end

    def perform_health_check(url)
      uri = URI.join(url, HEALTH_PATH)
      res = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 1, read_timeout: 2) do |http|
        http.get(uri.request_uri)
      end
      res.is_a?(Net::HTTPSuccess)
    rescue StandardError
      false
    end
  end
end
