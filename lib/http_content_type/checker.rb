require 'net/http'

module HttpContentType

  class Checker

    DEFAULT_OPTIONS = {
      timeout: 5
    }

    attr_accessor :expected_content_type, :options, :last_response

    # Creates a `HttpContentType::Checker` object given an asset URL and
    # options.
    #
    # @param asset_url [String] the asset URL
    # @param opts [Hash] misc options
    # @option opts [String] :timeout The read timeout for the `HEAD` request.
    # @option opts [String] :expected_content_type The expected `Content-Type`
    #   for the given `asset_url`.
    # @return [HttpContentType::Checker] the `HttpContentType::Checker` object
    def initialize(asset_url, opts = {})
      @asset_url = asset_url
      @expected_content_type = opts.delete(:expected_content_type)
      @options = DEFAULT_OPTIONS.merge(opts)
    end

    # Returns true if there was an error requesting the asset. Most common
    # errors are `HTTPClientError`, `HTTPServerError`, `HTTPUnknownResponse`.
    # Note that any other (less common) exceptions are catched as well.
    #
    # @return [Boolean] whether or not there was an error while requesting the
    #   asset.
    def error?
      !_head[:error].nil?
    end

    # Returns true if the asset was found (i.e. request returned an
    # `Net::HTTPSuccess` response).
    #
    # Note: You should always check for `#error?` before checking for `#found?`
    # to be sure you don't assume an asset doesn't exist when the request
    # actually errored!
    #
    # @return [Boolean] whether or not the asset exists
    def found?
      _head[:found]
    end

    # Returns true if the asset's `Content-Type` is valid according to its
    # extension.
    #
    # Note: This always returns true if `#error?` or `#found?` return true so
    # be sure to check for `#found?` before checking for
    # `#valid_content_type?`!
    #
    # @return [Boolean] whether or not the asset exists
    def valid_content_type?
      error? || !found? || content_type == expected_content_type
    end

    # Returns the `Content-Type` for the actually requested URL.
    #
    # Note: If the original URL included query parameters or redirected on
    # another URL, the `Content-Type` is the one for the actually requested URL
    # without the query parameters.
    #
    # @return [String] the `Content-Type` for the actual asset URL.
    # @see #expected_content_type
    def content_type
      _head[:content_type]
    end

    # Returns the expected `Content-Type` for the actually requested URL, based
    # on its extension or the `:expected_content_type` option passed when
    # instantiating the `HttpContentType::Checker` object.
    #
    # @return [String] the expected `Content-Type` for the actual asset URL.
    # @see #content_type
    def expected_content_type
      @expected_content_type ||= begin
        case File.extname(_head[:uri].path).sub(/^\./, '')
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

    private

    def _head
      @head ||= _fetch(@asset_url)
    end

    def _connection_options(uri)
      @_connection_options ||= { use_ssl: uri.scheme == 'https', read_timeout: options[:timeout] }
    end

    def _fetch(url, limit = 10)
      uri ||= URI.parse(URI.escape(url))

      return _other_error_response(uri, nil, error: 'Too many redirections') if limit == 0

      @last_response = Net::HTTP.start(uri.host, uri.port, _connection_options(uri)) do |http|
        req = Net::HTTP::Head.new(uri.request_uri)
        http.request(req)
      end

      case @last_response
      when Net::HTTPSuccess
        _success_response(uri, @last_response)
      when Net::HTTPRedirection
        _fetch(@last_response['location'], limit - 1)
      when Net::HTTPClientError
        _client_error_response(uri, @last_response)
      else
        _other_error_response(uri, @last_response)
      end

    rescue => ex
      puts "Exception from HttpContentType::Checker#_fetch('#{uri}', #{limit}):"
      puts ex
      _other_error_response(uri, @last_response, error: ex)
    end

    def _success_response(uri, http_response)
      _base_response(uri).merge(found: true, error: nil, content_type: http_response['content-type'])
    end

    def _client_error_response(uri, http_response)
      _base_response(uri).merge(found: false, error: nil, content_type: 'unknown')
    end

    def _other_error_response(uri, http_response, opts = {})
      error = opts[:error] || "#{http_response.code}: #{http_response.message}"

      _base_response(uri).merge(found: false, error: error, content_type: 'unknown')
    end

    def _base_response(uri)
      { uri: uri }
    end

  end

end
