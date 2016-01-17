require "excon"
require "json"

__LIB_DIR__ = File.expand_path(File.join(File.dirname(__FILE__), ".."))
unless $LOAD_PATH.include?(__LIB_DIR__)
  $LOAD_PATH.unshift(__LIB_DIR__)
end

require "inegi/api/version"

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
        path = "#{@options[:base_path]}#{params}/#{@api_key}"
        @connection.request(path: path)

      rescue Excon::Errors::HTTPStatusError => error
      end
    end
  end
end
