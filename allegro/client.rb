
class AllegroClient < Savon::Client
  def initialize(country_code, version_key, webapi_key)
    @country_code, @version_key, @webapi_key = country_code, version_key, webapi_key

    super() { wsdl.document = 'allegro.wsdl' }
  end

  def authenticate(login, password, webapi_key)
    response = request :do_login, body: {
      :"user-login"    => login,
      :"user-password" => password,
      :"webapi-key"    => @webapi_key,
      :"country-code"  => @country_code,
      :"local-version" => @version_key,
    }
    @session_handle = response.to_hash[:do_login_response][:session_handle_part]
  end
end

