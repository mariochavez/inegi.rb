require "test_helper"

class APITest < Minitest::Test
  Response = Struct.new(:status, :body)

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
      base_path: "/sistemas/api/indicadores/v1/Indicador/"
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
    stub_get_request(params)

    response = subject.request(params)

    assert_equal 200, response.status
  end

  def test_request_with_path_and_key
    subject = Inegi::API.new(api_key: key)
    stub_get_request(params, key)

    response = subject.request(params)

    assert_equal 200, response.status
  end

  def test_401_exception
    subject = Inegi::API.new(api_key: key)

    stub_request_with_error(Response.new(401, "Error"))

    assert_raises(Inegi::API::Errors::Unauthorized) do
      subject.request(params)
    end
  end

  def test_402_exception
    subject = Inegi::API.new(api_key: key)

    stub_request_with_error(Response.new(402, "Error"))

    assert_raises(Inegi::API::Errors::VerificationRequired) do
      subject.request(params)
    end
  end

  def test_403_exception
    subject = Inegi::API.new(api_key: key)

    stub_request_with_error(Response.new(403, "Error"))

    assert_raises(Inegi::API::Errors::Forbidden) do
      subject.request(params)
    end
  end

  def test_404_exception
    subject = Inegi::API.new(api_key: key)

    stub_request_with_error(Response.new(404, "Error"))

    assert_raises(Inegi::API::Errors::NotFound) do
      subject.request(params)
    end
  end

  def test_408_exception
    subject = Inegi::API.new(api_key: key)

    stub_request_with_error(Response.new(408, "Error"))

    assert_raises(Inegi::API::Errors::Timeout) do
      subject.request(params)
    end
  end

  def test_422_exception
    subject = Inegi::API.new(api_key: key)

    stub_request_with_error(Response.new(422, "Error"))

    assert_raises(Inegi::API::Errors::RequestFailed) do
      subject.request(params)
    end
  end

  def test_423_exception
    subject = Inegi::API.new(api_key: key)

    stub_request_with_error(Response.new(423, "Error"))

    assert_raises(Inegi::API::Errors::Locked) do
      subject.request(params)
    end
  end

  def test_429_exception
    subject = Inegi::API.new(api_key: key)

    stub_request_with_error(Response.new(429, "Error"))

    assert_raises(Inegi::API::Errors::RateLimitExceeded) do
      subject.request(params)
    end
  end

  def test_500_exception
    subject = Inegi::API.new(api_key: key)

    stub_request_with_error(Response.new(500, "Error"))

    assert_raises(Inegi::API::Errors::RequestFailed) do
      subject.request(params)
    end
  end

  def test_any_other_exception
    subject = Inegi::API.new(api_key: key)

    stub_request_with_error(Response.new(600, "Error"))

    assert_raises(Inegi::API::Errors::ErrorWithResponse) do
      subject.request(params)
    end
  end

  private
  def params
    @params ||= "1002000001/01/es/false"
  end

  def key
    @key ||= "1234"
  end

  def stub_request_with_error(response)
    stub_request(
      :get,
      /.*inegi.*/
    ).to_raise(
      Excon::Errors::HTTPStatusError.new(
        "Exception",
        nil,
        response)
    )
  end

  def stub_get_request(params, key = "", status = 200)
    stub_request(:get, get_url(params, key)).
    with(headers: Inegi::API::HEADERS).
    to_return(status: status, body: "{}", headers: {})
  end

  def get_url(params = "", key = "")
    options = Inegi::API::OPTIONS

    base_url = "#{options[:scheme]}://#{options[:host]}#{options[:base_path]}"
    if !params.empty?
      "#{base_url}#{params}/json/#{key}"
    else
      base_url
    end
  end
end
