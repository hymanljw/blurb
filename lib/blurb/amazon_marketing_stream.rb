require 'blurb/request'
require 'blurb/base_class'

class Blurb
  class AmazonMarketingStream < BaseClass
    attr_reader :base_url, :headers

    def initialize(headers:, base_url: nil, dsp: false, ads_account_id: nil)
      @base_url = "#{base_url}#{'/dsp' if dsp}/streams/subscriptions"
      @headers = headers.tap do |h|
        h["Content-Type"] = "application/vnd.MarketingStreamSubscriptions.#{:Dsp if dsp}StreamSubscriptionResource.v1.0+json"
        h["Amazon-Ads-Account-ID"] = ads_account_id if dsp
      end
    end

    def list(params = {})
      execute_request(
        request_type: :get,
        url_params: list_params(params)
      )
    end

    def list_params(params = {})
      _list_params_ = {}
      _list_params_[:maxResults] = params[:size].to_i if params[:size].present?
      _list_params_[:startingToken] = params[:next_token] if params[:next_token].present?
      _list_params_.presence
    end

    def retrieve(subscription_id)
      execute_request(
        request_type: :get,
        api_path: "/#{subscription_id}",
      )
    end

    def create(create_params)
      execute_request(
        request_type: :post,
        payload: create_params
      )
    end

    def update(subscription_id, **update_params)
      execute_request(
        request_type: :put,
        api_path: "/#{subscription_id}",
        payload: update_params
      )
    end

    private
      def execute_request(request_type:, api_path: '', payload: nil, url_params: nil)
        url = "#{@base_url}#{api_path}"
        request = Request.new(
          url:,
          url_params:,
          request_type:,
          payload: ,
          headers: @headers
        )

        request.make_request
      end
  end
end
