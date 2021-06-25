# frozen_string_literal: true

require "test_helper"

module Degreed
  module Content
    class CoursesTest < Minitest::Test
      def test_create_a_course
        create_request = stub_request(:post, "https://api.degreed.com/api/v2/content/courses")
          .with(
            headers: {
              "Authorization" => "Bearer someoauthtoken",
              "content-type" => "application/json"
            },
            body: {
              data: {
                type: "content/courses",
                attributes: {
                  title: "New Course",
                  summary: "A Summary",
                  "external-id": "arstaroisen",
                  url: "https://dev.lessonly.com",
                  duration: 200,
                  "duration-type": "Seconds"
                }
              }
            }.to_json
          )
          .to_return(
            status: 201,
            body: <<~JSON
              {
                "data": {
                  "type": "content/courses",
                  "id": "foo",
                  "attributes": {
                    "provider-code": null,
                    "external-id": "arstaroisen",
                    "degreed-url": "https://degreed.com/courses/?d=V9RVZY40PJ",
                    "title": "New Course",
                    "summary": "A Summary",
                    "url": "https://dev.lessonly.com",
                    "obsolete": false,
                    "image-url": null,
                    "language": null,
                    "duration": 200,
                    "duration-type": "Seconds",
                    "cost-units": 0.0,
                    "cost-unit-type": null,
                    "format": null,
                    "difficulty": null,
                    "video-url": null,
                    "created-at": "0001-01-01T00:00:00",
                    "modified-at": "0001-01-01T00:00:00"
                  },
                  "links": {
                    "self": "/content/courses/foo"
                  }
                }
              }
            JSON
          )

        response = Degreed::Content::Courses.new(token: "someoauthtoken").create(
          title: "New Course",
          summary: "A Summary",
          external_id: "arstaroisen",
          url: "https://dev.lessonly.com",
          duration: 200,
          duration_type: "Seconds"
        )

        assert_requested create_request
        assert_equal 201, response.code
        assert_equal "New Course", response.body.dig("data", "attributes", "title")
      end

      def test_get_courses_filtered_by_external_id
        courses_request = stub_request(:get, "https://api.degreed.com/api/v2/content/courses")
          .with(
            headers: { "Authorization" => "Bearer someoauthtoken" },
            query: {
              "filter[external_id]": "1234"
            }
          )
          .to_return(
            status: 200,
            body: <<~JSON
              {
                "links": {
                  "self": "https://api.degreed.com/api/v2/content/courses",
                  "next": "https://api.degreed.com/api/v2/content/courses?next=OomeEL"
                },
                "data": [
                  {
                    "type": "content/courses",
                    "id": "foo",
                    "attributes": {
                      "provider-code": null,
                      "external-id": "arstaroisen",
                      "degreed-url": "https://degreed.com/courses/?d=V9RVZY40PJ",
                      "title": "New Course",
                      "summary": "A Summary",
                      "url": "https://dev.lessonly.com",
                      "obsolete": false,
                      "image-url": null,
                      "language": null,
                      "duration": 200,
                      "duration-type": "Seconds",
                      "cost-units": 0.0,
                      "cost-unit-type": null,
                      "format": null,
                      "difficulty": null,
                      "video-url": null,
                      "created-at": "0001-01-01T00:00:00",
                      "modified-at": "0001-01-01T00:00:00"
                    },
                    "links": {
                      "self": "https://api.degreed.com/api/v2/content/courses/foo"
                    }
                  }
                ]
              }
            JSON
          )

        response = Degreed::Content::Courses.new(token: "someoauthtoken").all(
          external_id: "1234"
        )

        assert_requested courses_request
        assert_equal 200, response.code
        assert_equal "New Course", response.body["data"].first.dig("attributes", "title")
      end
    end
  end
end
