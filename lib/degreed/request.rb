# frozen_string_literal: true

require "net/http"

module Degreed
  # Request encapsulates the specifics of making requests to the Degreed API
  # for the common http verbs.
  class Request
    def initialize(token:)
      @token = token
    end

    # Get request
    #
    # @param uri [String]
    # @param params [Hash] query params for this request
    #
    # @return [Degreed::Response]
    def get(uri, params: {})
      uri = URI.parse(uri)
      uri.query = URI.encode_www_form(params) if params
      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Bearer #{@token}" if @token

      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end

      Response.new(res).raise_on_error
    end

    # Post request
    #
    # @param uri [String]
    # @param body [#to_json] post body
    #
    # @return [Degreed::Response]
    def post(uri, body: nil)
      uri = URI.parse(uri)
      req = Net::HTTP::Post.new(uri)
      req["Authorization"] = "Bearer #{@token}"
      req.body = body.to_json if body
      req["Content-Type"] = "application/json"

      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end

      Response.new(res).raise_on_error
    end
  end
end
