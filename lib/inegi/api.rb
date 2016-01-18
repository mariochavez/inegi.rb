require "excon"
require "json"

__LIB_DIR__ = File.expand_path(File.join(File.dirname(__FILE__), ".."))
unless $LOAD_PATH.include?(__LIB_DIR__)
  $LOAD_PATH.unshift(__LIB_DIR__)
end

require "inegi/api/version"
require "inegi/api/errors"

module Inegi
  class API
    HEADERS = {
      "Accept" => "application/json",
      "Accept-Encoding" => "gzip",
      "User-Agent" => "inegi-rb/#{Inegi::API::VERSION}",
      "X-Ruby-Version" => RUBY_VERSION,
      "X-Ruby-Platform" => RUBY_PLATFORM
    }

    OPTIONS = {
      host: "www3.inegi.org.mx",
      scheme: "http",
      headers: {},
      base_path: "sistemas/api/indicadores/v1/Indicador"
    }

    def initialize(options = {})
      @options = options.merge(OPTIONS)

      @api_key = @options.delete(:api_key) || ENV["INEGI_API_KEY"]
      @connection = Excon.new(
        "#{@options[:scheme]}://#{@options[:host]}",
        @options.merge(headers: HEADERS)
      )
    end

    def request(params)
      begin
        path = "#{@options[:base_path]}#{params}/json/#{@api_key}"
        @connection.request(path: path)
      rescue Excon::Errors::HTTPStatusError => error
        klass =
          case error.response.status
            when 401 then Inegi::API::Errors::Unauthorized
            when 402 then Inegi::API::Errors::VerificationRequired
            when 403 then Inegi::API::Errors::Forbidden
            when 404 then Inegi::API::Errors::NotFound
            when 408 then Inegi::API::Errors::Timeout
            when 422 then Inegi::API::Errors::RequestFailed
            when 423 then Inegi::API::Errors::Locked
            when 429 then Inegi::API::Errors::RateLimitExceeded
            when 500..509 then Inegi::API::Errors::RequestFailed
            else Inegi::API::Errors::ErrorWithResponse
          end

        response_error = klass.new(error.message, error.response)
        response_error.set_backtrace(error.backtrace)
        raise(response_error)
      end
    end
  end
end
