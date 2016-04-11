require 'json'
require 'uri'
require 'net/http'

module EphemeralCalc
  module GoogleAPI
    class OAuth

      SCOPES = [
        "https://www.googleapis.com/auth/userlocation.beacon.registry",
        "https://www.googleapis.com/auth/cloud-platform",
      ]

      REDIRECT_URI = "urn:ietf:wg:oauth:2.0:oob"
      TOKEN_URI = URI("https://www.googleapis.com/oauth2/v4/token")

      attr_accessor :client_id, :secret

      def initialize(client_id = ENV["GOOGLE_CLIENT_ID"], secret = ENV["GOOGLE_CLIENT_SECRET"])
        self.client_id = client_id
        self.secret = secret
      end

      def get_code
        system("open \"#{url}\"")
        printf "Copy and paste code from web browser here: "
        code = STDIN.gets.chomp
      end

      def get_credentials(old_credentials = Credentials.from_file)
        return old_credentials if old_credentials && !old_credentials.expired?
        http_opts = {use_ssl: true}
        response = Net::HTTP.start(TOKEN_URI.host, TOKEN_URI.port, http_opts) do |http|
          request = Net::HTTP::Post.new TOKEN_URI.request_uri
          request.body = if old_credentials == nil
                           {
                             code: get_code,
                             client_id: client_id,
                             client_secret: secret,
                             redirect_uri: REDIRECT_URI,
                             grant_type: "authorization_code",
                           }
                         else
                           # this is a refresh of the old credentials
                           {
                             refresh_token: old_credentials.refresh_token,
                             client_id: client_id,
                             client_secret: secret,
                             grant_type: "refresh_token",
                           }
                         end.map {|k,v| "#{k}=#{v}"}.join("&")
          request.add_field "Accept", "application/json"
          http.request request
        end
        if response.code.to_i == 200
          json = JSON.parse(response.body)
          credentials = Credentials.new(json)
          if old_credentials
            credentials.refresh_token = old_credentials.refresh_token
          end
          return credentials
        else
          raise RuntimeError, "Error #{response.code} (#{response.msg}) - #{TOKEN_URI}\n#{response.body}"
        end
      end

      def url
        "https://accounts.google.com/o/oauth2/v2/auth?scope=#{SCOPES.join("%20")}&redirect_uri=#{REDIRECT_URI}&response_type=code&client_id=#{client_id}"
      end
    end
  end
end
