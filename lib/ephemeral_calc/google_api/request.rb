require 'uri'
require 'net/http'
require 'base64'

module EphemeralCalc
  module GoogleAPI
    class Request
      extend Forwardable

      attr_accessor :method, :uri, :credentials
      def_delegators :request, :add_field, :body=

      def self.get(uri, credentials = nil)
        result = self.new(:get, uri, credentials)
        result.perform {|r| yield r if block_given? }
      end

      def self.post(uri, credentials = nil)
        result = self.new(:post, uri, credentials)
        result.perform {|r| yield r if block_given? }
      end

      def initialize(method, uri, credentials = nil)
        self.method = method
        self.uri = uri
        self.credentials = credentials
        yield self if block_given?
      end

      def perform
        http_opts = {use_ssl: true}
        response = Net::HTTP.start(uri.host, uri.port, http_opts) do |http|
          add_field "Authorization", "Bearer #{credentials.access_token}" if credentials
          add_field "Accept", "application/json"
          yield self if block_given?
          http.request request
        end
        if (200..299).include?(response.code.to_i)
          return response
        else
          raise RequestError.new(response.code.to_i), "Error #{response.code} (#{response.msg}) - #{uri}\n#{response.body}"
        end
      end

    private

      def request
        @request ||=
          begin
            case method
            when :get
              Net::HTTP::Get.new uri.request_uri
            when :post
              Net::HTTP::Post.new uri.request_uri
            end
          end
      end
    end

    class RequestError < StandardError
      attr_accessor :code
      def initialize(code)
        self.code = code
      end
    end

  end
end
