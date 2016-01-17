require "test_helper"

class APITest < Minitest::Test
  def test_api_with_empty_initialization
    subject = Inegi::API.new

    assert_kind_of Inegi::API, subject
  end

  def test_default_options
    subject = Inegi::API::OPTIONS

    options = {
      host: "www3.inegi.org.mx",
      scheme: "http",
      headers: {},
      base_path: "sistemas/api/indicadores/v1/Indicador"
    }

    assert_equal options, subject
  end

  def test_default_headers
    subject = Inegi::API::HEADERS

    headers = {
      "Accept" => "application/json",
      "Accept-Encoding" => "gzip",
      "User-Agent" => "inegi-rb/#{Inegi::API::VERSION}",
      "X-Ruby-Version" => RUBY_VERSION,
      "X-Ruby-Platform" => RUBY_PLATFORM
    }

    assert_equal headers, subject
  end

  def test_request_with_path
    subject = Inegi::API.new

    params = "/1002000001/01/es/false/json"

    stub_request(:get, get_url(params)).
    with(headers: Inegi::API::HEADERS).
    to_return(status: 200, body: "{}", headers: {})

    response = subject.request(params)

    assert_equal 200, response.status
  end

  def test_request_with_path_and_key
    key = "1234"
    params = "/1002000001/01/es/false/json"

    subject = Inegi::API.new(api_key: key)

    stub_request(:get, get_url(params, key)).
    with(headers: Inegi::API::HEADERS).
    to_return(status: 200, body: "{}", headers: {})

    response = subject.request(params)

    assert_equal 200, response.status
  end

  private

  def get_url(params = "", key = "")
    options = Inegi::API::OPTIONS

    base_url = "#{options[:scheme]}://#{options[:host]}/#{options[:base_path]}"
    if !params.empty?
      "#{base_url}#{params}/#{key}"
    else
      base_url
    end
  end
end
