require 'blurb/request'
require 'blurb/base_class'

class Blurb
  class SbV4RequestCollection < BaseClass
    attr_accessor :api_limit
    attr_reader :base_url, :resource_type, :resource_key, :headers, :api_path

    def initialize(headers:, resource_type:, base_url: nil, bulk_api_limit: 10)
      @base_url = base_url
      @resource_type = resource_type.to_s
      @resource_key = camel_resource_key(@resource_type)
      @headers = headers
      @api_limit = bulk_api_limit
    end

    def content_type_context
      if @resource_type.to_s.in?(%w[campaign ad_group ad])
        "application/vnd.sb#{@resource_type.to_s.gsub(/[_]/, '').downcase}resource.v4+json"
      elsif @resource_type.to_s == "ad_creative"
        "application/vnd.sbAdCreativeResource.v4+json"
      elsif @resource_type.to_s == "product_targeting_category" || @api_path == "/negativeTargets/brands/recommendations"
        "application/vnd.sbtargeting.v4+json"
      elsif @api_path == "/campaigns/budgetRecommendations"
        "application/vnd.sbbudgetrecommendation.v4+json"
      elsif @resource_type.to_s == "insight"
        "application/vnd.sbinsights.v4+json"
      elsif @resource_type.to_s == "budget_usage"
        "application/vnd.sbcampaignbudgetusage.v1+json"
      elsif @resource_type.to_s == "forecast"
        "application/vnd.sbforecasting.v4+json"
      else
        # @resource_type.to_s == "budget_rule" || @api_path == "/recommendations/creative/headline"
        "application/json"
      end
    end

    def camel_resource_key(resource_type)
      resource_type.singularize.camelcase(:lower)
    end

    def snake_resource_key(plural = true)
      @resource_key.send( plural ? :pluralize : :singularize).underscore.to_sym
    end

    def list(params = {})
      execute_request(
        api_path: "/list",
        request_type: :post,
        payload: list_params(params)
      ).transform_keys {|k| k == snake_resource_key ? :list : k }
    end

    def list_params(params = {})
      _list_params_ = {}
      _list_params_[:maxResults] = params[:size].to_i if params[:size].present?
      _list_params_[:nextToken] = params[:next_token] if params[:next_token].present?
      _list_params_[:stateFilter] = {include: Array(params[:state_filter]).map(&:upcase)} if params[:state_filter].present?
      _list_params_[:includeExtendedDataFields] = params[:extend] != false

      _list_params_[:portfolioIdFilter] = {include: Array(params[:portfolio_id_filter]).map(&:to_s)} if params[:portfolio_id_filter].present?
      _list_params_[:campaignIdFilter] = {include: Array(params[:campaign_id_filter]).map(&:to_s)} if params[:campaign_id_filter].present?
      _list_params_[:adGroupIdFilter] = {include: Array(params[:ad_group_id_filter]).map(&:to_s)} if params[:ad_group_id_filter].present?
      _list_params_[:keywordIdFilter] = {include: Array(params[:keyword_id_filter]).map(&:to_s)} if params[:keyword_id_filter].present?
      _list_params_[:targetIdFilter] = {include: Array(params[:target_id_filter]).map(&:to_s)} if params[:target_id_filter].present?
      _list_params_[:adIdFilter] = {include: Array(params[:ad_id_filter]).map(&:to_s)} if params[:ad_id_filter].present?
      _list_params_[:negativeKeywordIdFilter] = {include: Array(params[:ng_keyword_id_filter]).map(&:to_s)} if params[:ng_keyword_id_filter].present?
      _list_params_[:negativeTargetIdFilter] = {include: Array(params[:ng_target_id_filter]).map(&:to_s)} if params[:ng_target_id_filter].present?
      _list_params_[:campaignNegativeKeywordIdFilter] = {include: Array(params[:campaign_ng_keyword_id_filter]).map(&:to_s)} if params[:campaign_ng_keyword_id_filter].present?
      _list_params_[:campaignNegativeTargetIdFilter] = {include: Array(params[:campaign_ng_target_id_filter]).map(&:to_s)} if params[:campaign_ng_target_id_filter].present?
      _list_params_[:campaignTargetingTypeFilter] = params[:targeting_type_filter] if params[:targeting_type_filter].present?

      _list_params_[:locale] = params[:locale] if params[:locale].present?
      _list_params_[:matchTypeFilter] = Array(params[:match_type_filter]) if params[:match_type_filter].present?
      _list_params_[:expressionTypeFilter] = {include: Array(params[:exp_type_filter])} if params[:exp_type_filter].present?
      _list_params_[:nameFilter] = { queryTermMatchType: params[:term_type] || "BROAD_MATCH", include: Array(params[:name_filter]) } if params[:name_filter].present?
      _list_params_[:keywordTextFilter] = { queryTermMatchType: params[:term_type] || "BROAD_MATCH", include: Array(params[:kw_filter]) } if params[:kw_filter].present?
      _list_params_[:negativeKeywordTextFilter] = { queryTermMatchType: params[:term_type] || "BROAD_MATCH", include: Array(params[:ng_kw_filter]) } if params[:ng_kw_filter].present?
      _list_params_[:campaignNegativeKeywordTextFilter] = { queryTermMatchType: params[:term_type] || "BROAD_MATCH", include: Array(params[:campagin_ng_kw_filter]) } if params[:campagin_ng_kw_filter].present?
      _list_params_[:asinFilter] = { queryTermMatchType: params[:term_type] || "BROAD_MATCH", include: Array(params[:asin_filter]) } if params[:asin_filter].present?
      _list_params_[:ad_id] = params[:ad_id] if params[:ad_id].present?
      _list_params_[:creativeVersionFilter] = params[:creative_version_filter] if params[:creative_version_filter].present?
      _list_params_[:creativeStatusFilter] = params[:creative_status_filter] if params[:creative_status_filter].present?
      _list_params_
    end

    def retrieve(resource_id)
      list({"#{@resource_type}_id_filter".to_sym => resource_id})[0]
    end

    def create(**create_params)
      create_bulk([create_params])
    end

    def create_bulk(create_array)
      execute_bulk_request(
        request_type: :post,
        payload: create_array
      )
    end

    def update(**update_params)
      update_bulk([update_params])
    end

    def update_bulk(update_array)
      execute_bulk_request(
        request_type: :put,
        payload: update_array
      )
    end

    def delete(resource_ids)
      results = []
      payload_key = "#{@resource_type.sub(/product_ad/, 'ad').camelcase(:lower)}IdFilter"
      execute_request_params = {api_path: "/delete", request_type: :post}
      Array(resource_ids).each_slice(@api_limit) do |p|
        execute_request_params[:payload] = { payload_key => { include: p } }
        results << assemble_results(execute_request(**execute_request_params))
      end
      results.flatten
    end

    # send a request in api_path
    def launch_request(api_path, request_type, **params)
      @api_path = api_path
      execute_request(request_type: , **params.slice(:payload, :url_params))
    end

    private
      def execute_request(request_type: , api_path: nil, payload: nil, url_params: nil)
        url = "#{@base_url}#{api_path || @api_path}"
        _content_type = content_type_context
        request = Request.new(
          url: , url_params: , request_type: , payload: ,
          headers: @headers.merge("Content-Type" => _content_type, "Accept" => _content_type)
        )
        request.make_request
      end

      # Split up bulk requests to match the api limit
      def execute_bulk_request(**execute_request_params)
        results = []
        payloads = execute_request_params[:payload].each_slice(@api_limit).to_a
        payloads.each do |p|
          execute_request_params[:payload] = { @resource_key.pluralize => p }
          results << assemble_results(execute_request(**execute_request_params))
        end
        results.flatten
      end

      def assemble_results(response_data)
        success_results, error_results = response_data[snake_resource_key].values_at(:success, :error)
        error_results.each do |item|
          success_results.insert(item[:index], item)
        end
        success_results
      end
  end
end
