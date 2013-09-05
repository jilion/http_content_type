require 'net/http'

module HttpContentType

  class Checker
    UNKNOWN_CONTENT_TYPE_RESPONSE = { content_type: 'unknown' }
    FILE_NOT_FOUND_RESPONSE = { found: false, content_type: 'unknown' }

    attr_accessor :last_response

    def initialize(asset_url, opts = {})
      @asset_url = asset_url
      @expected_content_type = opts.delete(:expected_content_type)
      @options = DEFAULT_OPTIONS.merge(opts)
    end

    def error?
      !_head[:error].nil?
    end

    def found?
      _head[:found]
    end

    def expected_content_type
      @expected_content_type ||= begin
        case File.extname(_head[:location].path).sub(/^\./, '')
        when 'mp4', 'm4v', 'mov'
          'video/mp4'
        when 'webm'
          'video/webm'
        when 'ogv', 'ogg'
          'video/ogg'
        else
          'unknown'
        end
      end
    end

    def content_type
      _head[:content_type]
    end

    def valid_content_type?
      content_type == expected_content_type
    end

    private

    def _head
      @head ||= _fetch(@asset_url)
    end

    def _connection_options(uri)
      @_connection_options ||= { use_ssl: uri.scheme == 'https', read_timeout: options[:timeout] }
    end

    def _fetch(url, limit = 10)
      raise TooManyRedirections if limit == 0

      uri ||= URI.parse(URI.escape(url))
      @last_response = Net::HTTP.start(uri.host, uri.port, _connection_options(uri)) do |http|
        req = Net::HTTP::Head.new(uri.request_uri)
        http.request(req)
      end

      simplified_response = { location: uri, found: true, content_type: @last_response['content-type'] }


      case @last_response
      when Net::HTTPSuccess
        simplified_response
      when Net::HTTPRedirection
        _fetch(@last_response['location'], limit - 1)
      when Net::HTTPClientError
        simplified_response.merge(FILE_NOT_FOUND_RESPONSE)
      else
        simplified_response.merge(UNKNOWN_CONTENT_TYPE_RESPONSE)
      end

    rescue => ex
      puts "Exception from HttpContentType::Checker#_fetch('#{uri}', #{limit}):"
      puts ex
      # puts ex.backtrace
      UNKNOWN_CONTENT_TYPE_RESPONSE
    end

  end

end
