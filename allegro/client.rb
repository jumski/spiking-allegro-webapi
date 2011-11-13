
class AllegroClient < Savon::Client
  SESSION_HANDLE_FILE = 'tmp/session_handle.dump'

  def initialize(*args)
    @country_code, @version_key, @webapi_key, @login, @password = *args
    super() { wsdl.document = 'allegro.wsdl' }
  end

  def authenticate
    response = request :do_login, body: {
      "user-login"    => @login,
      "user-password" => @password,
      "webapi-key"    => @webapi_key,
      "country-code"  => @country_code,
      "local-version" => @version_key,
    }
    handle = response.to_hash[:do_login_response][:session_handle_part]

    File.open(SESSION_HANDLE_FILE, 'w') do |file|
      file.write handle
    end

    handle
  end

  def session_handle
    path = SESSION_HANDLE_FILE

    if File.exists?(path)
      if Time.now.to_i - File.mtime(path).to_i > 3000
        handle = authenticate
      else
        handle = File.open(path, 'r').read
      end
    else
      handle = authenticate
    end

    handle
  end

  def make_auction(item)
    begin
      # request :do_check_new_auction_ext, body: { :'session-handle' => session_handle, :'fields' => item.to_fields }
      request :do_new_auction_ext, body: { :'session-handle' => session_handle, :'fields' => item.to_fields }
    rescue 
      puts
      puts '-----------------------------'
      puts $!
      puts '-----------------------------'
    end
  end
end

