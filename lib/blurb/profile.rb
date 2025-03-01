# frozen_string_literal: true

require 'blurb/account'
require 'blurb/campaign_requests'
require 'blurb/snapshot_requests'
require 'blurb/report_requests'
require 'blurb/report_v3_requests'
require 'blurb/request_collection'
require 'blurb/request_collection_with_campaign_type'
require 'blurb/suggested_keyword_requests'
require 'blurb/history_request'
require 'blurb/product_request'
require 'blurb/bid_recommendation_requests'
require 'blurb/budget_recommendation_requests'
require 'blurb/budget_rules_recommendation_requests'
require 'blurb/sp_v3_request_collection'
require 'blurb/amazon_marketing_stream'
require 'blurb/bid_recommendation_v3_requests'
require 'blurb/sb_v4_request_collection'
require 'blurb/sb_v3_request_collection'
require 'blurb/export_requests'

require 'blurb/concerns/sb_requests'


class Blurb
  class Profile < BaseClass
    include SbRequests

    attr_accessor(
      :account,
      :ad_groups,
      :sd_ad_groups,
      :campaign_negative_keywords,
      :portfolios,
      :product_ads,
      :sd_product_ads,
      :profile_id,
      :suggested_keywords,
      :targets,
      :history,
      :products,
      :sp_reports_v3,
      # SP V3
      :sp_campaigns_v3,
      :sp_ad_groups_v3,
      :sp_product_ads_v3,
      :sp_keywords_v3,
      :sp_targets_v3,
      :sp_campaign_negative_keywords_v3,
      :sp_campaign_negative_targets_v3,
      :sp_negative_keywords_v3,
      :sp_negative_targets_v3,
      :sp_bid_recommendation_v3
    )

    def initialize(profile_id:, account:)
      @profile_id = profile_id
      @account = account
      initialize_requests
    end

    def initialize_requests
      @sp_campaigns = CampaignRequests.new(
        headers: headers_hash,
        base_url: account.api_url,
        resource: 'campaigns',
        campaign_type: CAMPAIGN_TYPE_CODES[:sp]
      )
      @sb_campaigns = CampaignRequests.new(
        headers: headers_hash,
        base_url: account.api_url,
        resource: 'campaigns',
        campaign_type: CAMPAIGN_TYPE_CODES[:sb],
        bulk_api_limit: 10
      )
      @sd_campaigns = CampaignRequests.new(
        headers: headers_hash,
        base_url: account.api_url,
        resource: 'campaigns',
        campaign_type: CAMPAIGN_TYPE_CODES[:sd],
        bulk_api_limit: 10
      )
      @sp_keywords = RequestCollectionWithCampaignType.new(
        headers: headers_hash,
        base_url: account.api_url,
        resource: 'keywords',
        campaign_type: CAMPAIGN_TYPE_CODES[:sp]
      )
      @sb_keywords = RequestCollectionWithCampaignType.new(
        headers: headers_hash,
        base_url: account.api_url,
        resource: 'keywords',
        campaign_type: CAMPAIGN_TYPE_CODES[:sb]
      )
      @sp_snapshots = SnapshotRequests.new(
        headers: headers_hash,
        base_url: account.api_url,
        campaign_type: CAMPAIGN_TYPE_CODES[:sp]
      )
      @sd_snapshots = SnapshotRequests.new(
        headers: headers_hash,
        base_url: @account.api_url,
        campaign_type: CAMPAIGN_TYPE_CODES[:sd]
      )
      @sb_snapshots = SnapshotRequests.new(
        headers: headers_hash,
        base_url: account.api_url,
        campaign_type: :hsa
      )
      @sp_reports = ReportRequests.new(
        headers: headers_hash,
        base_url: account.api_url,
        campaign_type: CAMPAIGN_TYPE_CODES[:sp]
      )
      @sd_reports = ReportRequests.new(
        headers: headers_hash,
        base_url: account.api_url,
        campaign_type: CAMPAIGN_TYPE_CODES[:sd]
      )
      @sb_reports = ReportRequests.new(
        headers: headers_hash,
        base_url: account.api_url,
        campaign_type: :hsa
      )
      @ad_groups = RequestCollection.new(
        headers: headers_hash,
        base_url: "#{account.api_url}/v2/sp/adGroups"
      )
      @sd_ad_groups = RequestCollection.new(
        headers: headers_hash,
        base_url: "#{account.api_url}/sd/adGroups"
      )
      @product_ads = RequestCollection.new(
        headers: headers_hash,
        base_url: "#{account.api_url}/v2/sp/productAds"
      )
      @sd_product_ads = RequestCollection.new(
        headers: headers_hash,
        base_url: "#{account.api_url}/sd/productAds"
      )
      @sp_negative_keywords = RequestCollectionWithCampaignType.new(
        headers: headers_hash,
        base_url: account.api_url,
        resource: 'negativeKeywords',
        campaign_type: CAMPAIGN_TYPE_CODES[:sp]
      )
      @sp_negative_targets = RequestCollectionWithCampaignType.new(
        headers: headers_hash,
        base_url: account.api_url,
        resource: 'negativeTargets',
        campaign_type: CAMPAIGN_TYPE_CODES[:sp]
      )
      @sb_negative_keywords = RequestCollectionWithCampaignType.new(
        headers: headers_hash,
        base_url: account.api_url,
        resource: 'negativeKeywords',
        campaign_type: CAMPAIGN_TYPE_CODES[:sb]
      )
      @campaign_negative_keywords = RequestCollection.new(
        headers: headers_hash,
        base_url: "#{account.api_url}/v2/sp/campaignNegativeKeywords"
      )
      @targets = RequestCollection.new(
        headers: headers_hash,
        base_url: "#{account.api_url}/v2/sp/targets"
      )
      # @portfolios = RequestCollection.new(
      #   headers: headers_hash,
      #   base_url: "#{account.api_url}/v2/portfolios"
      # )
      @portfolios = SpV3RequestCollection.new(
        headers: headers_hash,
        resource_type: :portfolio,
        base_url: "#{account.api_url}/portfolios"
      )
      @suggested_keywords = SuggestedKeywordRequests.new(
        headers: headers_hash,
        base_url: "#{account.api_url}/v2/sp"
      )
      @history = HistoryRequest.new(
        headers: headers_hash,
        base_url: account.api_url
      )
      @sp_bid_recommendations = BidRecommendationRequests.new(
        headers: headers_hash,
        base_url: account.api_url,
        campaign_type: CAMPAIGN_TYPE_CODES[:sp]
      )
      @sp_budget_recommendations = BudgetRecommendationRequests.new(
        headers: headers_hash,
        base_url: account.api_url,
        campaign_type: CAMPAIGN_TYPE_CODES[:sp]
      )
      @sp_budget_rules_recommendations = BudgetRulesRecommendationRequests.new(
        headers: headers_hash,
        base_url: account.api_url,
        campaign_type: CAMPAIGN_TYPE_CODES[:sp]
      )
      @products = ProductRequest.new(
        headers: headers_hash,
        base_url: account.api_url
      )
      @sp_reports_v3 = ReportV3Requests.new(
        headers: headers_hash,
        base_url: account.api_url,
        campaign_type: CAMPAIGN_TYPE_CODES[:sp]
      )
      @sp_campaigns_v3 = SpV3RequestCollection.new(
        headers: headers_hash,
        resource_type: :campaign,
        base_url: "#{account.api_url}/sp/campaigns"
      )
      @sp_ad_groups_v3 = SpV3RequestCollection.new(
        headers: headers_hash,
        resource_type: :ad_group,
        base_url: "#{account.api_url}/sp/adGroups"
      )
      @sp_product_ads_v3 = SpV3RequestCollection.new(
        headers: headers_hash,
        resource_type: :product_ad,
        base_url: "#{account.api_url}/sp/productAds"
      )
      @sp_keywords_v3 = SpV3RequestCollection.new(
        headers: headers_hash,
        resource_type: :keyword,
        base_url: "#{account.api_url}/sp/keywords"
      )
      @sp_targets_v3 = SpV3RequestCollection.new(
        headers: headers_hash,
        resource_type: :target,
        base_url: "#{account.api_url}/sp/targets"
      )
      @sp_campaign_negative_keywords_v3 = SpV3RequestCollection.new(
        headers: headers_hash,
        resource_type: :campaign_negative_keyword,
        base_url: "#{account.api_url}/sp/campaignNegativeKeywords"
      )
      @sp_campaign_negative_targets_v3 = SpV3RequestCollection.new(
        headers: headers_hash,
        resource_type: :campaign_negative_target,
        base_url: "#{account.api_url}/sp/campaignNegativeTargets"
      )
      @sp_negative_keywords_v3 = SpV3RequestCollection.new(
        headers: headers_hash,
        resource_type: :negative_keyword,
        base_url: "#{account.api_url}/sp/negativeKeywords"
      )
      @sp_negative_targets_v3 = SpV3RequestCollection.new(
        headers: headers_hash,
        resource_type: :negative_target,
        base_url: "#{account.api_url}/sp/negativeTargets"
      )
      @sp_bid_recommendation_v3 = BidRecommendationV3Requests.new(
        headers: headers_hash,
        base_url: account.api_url,
        campaign_type: CAMPAIGN_TYPE_CODES[:sp]
      )
    end

    def campaigns(campaign_type)
      return @sp_campaigns_v3 if campaign_type == :sp
      return @sb_campaigns if %i[sb hsa].include?(campaign_type)
      return @sd_campaigns if campaign_type == :sd
    end

    def keywords(campaign_type)
      return @sp_keywords_v3 if campaign_type == :sp
      return @sb_keywords if %i[sb hsa].include?(campaign_type)
    end

    def negative_keywords(campaign_type)
      return @sp_negative_keywords_v3 if campaign_type == :sp
      return @sb_negative_keywords if %i[sb hsa].include?(campaign_type)
    end

    def negative_targets(campaign_type)
      @sp_negative_targets_v3 if campaign_type == :sp
    end

    def snapshots(campaign_type)
      return @sp_snapshots if campaign_type == :sp
      return @sb_snapshots if %i[sb hsa].include?(campaign_type)
      return @sd_snapshots if campaign_type == :sd
    end

    def reports(campaign_type)
      return @sp_reports if campaign_type == :sp
      return @sb_reports if %i[sb hsa].include?(campaign_type)
      return @sd_reports if campaign_type == :sd
    end

    def reports_v3(campaign_type)
      var_name = :"@#{campaign_type}_reports_v3"
      instance_variable_get(var_name) or
        instance_variable_set(
          var_name,
          ReportV3Requests.new(
            headers: headers_hash,
            base_url: account.api_url,
            campaign_type: campaign_type.to_s))
    end

    def bid_recommendations(campaign_type)
      return @sp_bid_recommendations if campaign_type == :sp
      return @sb_bid_recommendations if %i[sb hsa].include?(campaign_type)
      return @sd_bid_recommendations if campaign_type == :sd
    end

    def budget_recommendations(campaign_type)
      return @sp_budget_recommendations if campaign_type == :sp
      return @sb_budget_recommendations if %i[sb hsa].include?(campaign_type)
      return @sd_budget_recommendations if campaign_type == :sd
    end

    def budget_rules_recommendations(campaign_type)
      return @sp_budget_rules_recommendations if campaign_type == :sp
      return @sb_budget_rules_recommendations if %i[sb hsa].include?(campaign_type)
      return @sd_budget_rules_recommendations if campaign_type == :sd
    end

    def request(api_path: '', request_type: :get, payload: nil, url_params: nil, headers: headers_hash)
      @base_url = @account.api_url

      url = "#{@base_url}#{api_path}"

      request = Request.new(
        url:,
        url_params:,
        request_type:,
        payload:,
        headers:
      )

      request.make_request
    end

    def profile_details
      @account.retrieve_profile(@profile_id)
    end

    def headers_hash(opts = {})
      headers_hash = {
        'Authorization' => "Bearer #{@account.retrieve_token}",
        'Content-Type' => 'application/json',
        'Amazon-Advertising-API-Scope' => @profile_id,
        'Amazon-Advertising-API-ClientId' => @account.client.client_id
      }

      headers_hash['Content-Encoding'] = 'gzip' if opts[:gzip]

      headers_hash
    end

    def stream_subscriptions
      @_stream_subscriptions ||= AmazonMarketingStream.new(
        headers: headers_hash,
        base_url: account.api_url
      )
    end

    def exports(record_type)
      @exports ||= ExportRequests.new(headers: headers_hash, base_url: account.api_url)
      @exports.record_type = record_type
      @exports
    end
  end
end
