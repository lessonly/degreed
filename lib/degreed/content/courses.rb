# frozen_string_literal: true

module Degreed
  module Content
    # Methods for calling Degreed endpoints for creating, managing, and
    # retrieving courses.
    #
    # @see https://api.degreed.com/docs/#content-courses
    class Courses
      def initialize(token:)
        @token = token
      end

      def dasherize(underscored_word)
        underscored_word.tr("_", "-")
      end

      # Create a course
      #
      # @see https://api.degreed.com/docs/#create-a-new-course
      #
      # @param title [String]
      # @param external_id [String, #to_s]
      # @param url [String]
      # @param duration [Integer, #to_i]
      # @param duration_type [String]
      #   Accepted values: Seconds, Minutes, Hours, or Days
      # @param summary [String] Optional (default: nil)
      #
      # @return [Degreed::Response]
      def create(title:, external_id:, url:, duration:, duration_type:, **kwargs)
        request.post(
          content_courses_url,
          body: {
            data: {
              type: "content/courses",
              attributes: {
                title: title,
                summary: kwargs.fetch(:summary, nil),
                "external-id": String(external_id),
                url: url,
                duration: Integer(duration),
                "duration-type": duration_type
              }
            }
          }
        )
      end

      # List courses
      #
      # @see https://api.degreed.com/docs/#get-all-courses
      #
      # @param external_id [String, #to_s] Optional filter
      #
      # @return [Degreed::Response]
      def all(external_id: nil)
        params = {}
        params["filter[external_id]"] = String(external_id) if external_id

        request.get(content_courses_url, params: params)
      end

      # Update course
      #
      # @see https://api.degreed.com/docs/#update-a-specific-course
      #
      # @param title [String]
      # @param external_id [String, #to_s]
      # @param url [String]
      # @param duration [Integer, #to_i]
      # @param duration_type [String]
      #   Accepted values: Seconds, Minutes, Hours, or Days
      # @param summary [String] Optional (default: nil)
      #
      # @return [Degreed::Response]
      def update(id:, **kwargs)
        allowed_attributes = %w[
          title
          url
          duration
          duration-type
          obsolete
          summary
        ]
        updated_attrs = kwargs
          .transform_keys(&:to_s)
          .transform_keys { |key| dasherize(key) }
          .filter { |key| allowed_attributes.include? key }
        body = {
          data: {
            type: "content/courses",
            id: id,
            attributes: updated_attrs
          }
        }

        request.patch(content_course_url(id), body: body)
      end

      private

      def request
        Request.new(token: @token)
      end

      def content_courses_url
        "#{Degreed.config.base_url}/content/courses"
      end

      def content_course_url(id)
        "#{content_courses_url}/#{id}"
      end
    end
  end
end
