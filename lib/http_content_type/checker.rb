require 'net/http'

module HttpContentType

  class Checker
    UNKNOWN_CONTENT_TYPE_RESPONSE = { 'found' => true, 'content-type' => 'unknown' }
    FILE_NOT_FOUND_RESPONSE = { 'found' => false, 'content-type' => 'unknown' }

    def initialize(asset_url)
      @asset_url = asset_url
    end

    def found?
      _head['found']
    end

    def expected_content_type
      @expected_content_type ||= case File.extname(@asset_url).sub(/^\./, '')
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

    def content_type
      _head['content-type']
    end

    def valid_content_type?
      content_type == expected_content_type
    end

    private

    def _clean_uri
      @_clean_uri ||= URI.parse(URI.escape(@asset_url))
    end

    def _head_options
      @_head_options ||= { use_ssl: _clean_uri.scheme == 'https', read_timeout: 3 }
    end

    def _head
      @response ||= begin
        response = Net::HTTP.start(_clean_uri.host, _clean_uri.port, _head_options) do |http|
          http.head(_clean_uri.path)
        end

        case response
        when Net::HTTPSuccess, Net::HTTPRedirection
          { 'found' => true, 'content-type' => response['content-type'] }
        when Net::HTTPClientError
          FILE_NOT_FOUND_RESPONSE
        else
          UNKNOWN_CONTENT_TYPE_RESPONSE
        end

      rescue
        UNKNOWN_CONTENT_TYPE_RESPONSE
      end
    end

  end

end
