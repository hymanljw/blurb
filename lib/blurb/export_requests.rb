require 'blurb/request'
require 'blurb/base_class'

class Blurb
  class ExportRequests < BaseClass
    attr_accessor :record_type
    attr_reader :base_url, :resource_type

    def initialize(base_url:, headers:)
      # @resource_type = resource_type
      @base_url = base_url
      @headers = headers
    end

    # record_type => [:campagin, :ad_group, :ad, :target]
    def create(state_filter = nil, ad_product_filter = nil, **params)
      # state_filter default => ["ENABLED", "PAUSED","ARCHIVED"],
      # ad_product_filter default => ["SPONSORED_PRODUCTS","SPONSORED_BRANDS","SPONSORED_DISPLAY"]
      execute_request(
        api_path: "/#{@record_type.to_s.pluralize.camelize(:lower)}/export",
        request_type: :post,
        payload: { state_filter: , ad_product_filter: , **params.slice(:target_type_filter, :target_level_filter, :negative_filter)}.compact,
        headers: @headers.merge(record_type_headers)
      )
    end

    def record_type_headers
      _content_type = "application/vnd.#{@record_type.to_s.gsub(/_/, '').pluralize}export.v1+json"
      {"Content-Type" => _content_type, "Accept" => _content_type}
    end

    def retrieve(export_id)
      execute_request(
        api_path: "/exports/#{export_id}", request_type: :get,
        headers: @headers.merge(record_type_headers)
      )
    end

    def download(export_id)
      download_url = retrieve(export_id)[:url]
      RestClient.get(download_url).body
    end

    private
      def execute_request(request_type:, api_path: '', payload: nil, url_params: nil, headers: )
        url = "#{@base_url}#{api_path}"
        request = Request.new(url:, url_params:, request_type:, payload:, headers:)
        request.make_request
      end
  end
end
