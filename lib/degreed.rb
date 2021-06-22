# frozen_string_literal: true

require "json"
require "degreed/version"
require "degreed/request"
require "degreed/response"
require "degreed/content/courses"

# Client for the Degreed API
module Degreed
  # Access the current configuration
  def configuration
    @configuration ||= Configuration.new
  end
  module_function :configuration

  # Alias so that we can refer to configuration as config
  def config
    configuration
  end
  module_function :config

  # Configure the library
  #
  # @yieldparam [Degreed::Configuration] current_configuration
  #
  # @example
  #   Degreed.configure do |config|
  #     config.base_url = "www.foobar.com"
  #   end
  #
  # @yieldreturn [Degreed::Configuration]
  def configure
    yield configuration
  end
  module_function :configure

  # Configuration holds the current configuration for the Degreed
  # and provides defaults
  class Configuration
    attr_accessor :base_url

    def initialize(args = {})
      @base_url = args.fetch(:base_url, "https://api.degreed.com/api/v2")
    end
  end

  # Base level client for Degreed.
  # You can access other sub clients through this class if desired.
  #
  # @param token [String] valid oauth token
  #
  # @example Accessing courses
  #   Degreed::Client.new(token: "token").courses
  class Client
    def initialize(token: nil)
      @token = token
    end

    # Access the courses client
    #
    # @return [Degreed::Content::Courses]
    def courses
      Content::Courses.new(token: @token)
    end
  end
end
