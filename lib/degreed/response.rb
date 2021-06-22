# frozen_string_literal: true

require "forwardable"

module Degreed
  class Error < StandardError; end

  class DegreedError < Error; end

  class HTTPClientError < DegreedError; end

  class HTTPServerError < DegreedError; end

  class HTTPBadRequest < HTTPClientError; end

  class HTTPUnauthorized < HTTPClientError; end

  class HTTPForbidden < HTTPClientError; end

  # Response represents a response from Degreed.
  #
  # It is returned when using methods in Request.
  # @see Degreed::Request
  class Response
    attr_reader :raw_response

    extend Forwardable
    # def_delegators :@raw_response, :code

    def initialize(response)
      @raw_response = response
    end

    # Was the response code 2xx
    #
    # @return [Boolean]
    def success?
      @raw_response.is_a?(Net::HTTPSuccess)
    end

    def code
      Integer(@raw_response.code)
    end

    # Body of the request
    #
    # @return [Hash] request body
    def body
      return {} if @raw_response.body.strip.empty?

      JSON.parse(@raw_response.body)
    end

    def raise_on_error
      exception_class =
        case code
        when 400 then HTTPBadRequest
        when 401 then HTTPUnauthorized
        when 403 then HTTPForbidden
        when (400...500) then HTTPClientError
        when (500...600) then HTTPServerError
        end

      raise exception_class, "HTTP code: #{code}, message: #{body.dig('error', 'message')}" if exception_class

      self
    end
  end
end
