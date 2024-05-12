require 'blurb/sb_v4_request_collection'
require 'blurb/sb_v3_request_collection'

module SbRequests

  def sb_campaigns_v4
    @sb_campaigns_v4 ||= Blurb::SbV4RequestCollection.new(
      headers: headers_hash,
      resource_type: :campaign,
      base_url: "#{account.api_url}/sb/v4/campaigns")
  end

  def sb_ad_groups_v4
    @sb_ad_groups_v4 ||= Blurb::SbV4RequestCollection.new(
      headers: headers_hash,
      resource_type: :ad_group,
      base_url: "#{account.api_url}/sb/v4/adGroups")
  end

  def sb_ads_v4
    @sb_ads_v4 ||= Blurb::SbV4RequestCollection.new(
      headers: headers_hash,
      resource_type: :ad,
      base_url: "#{account.api_url}/sb/v4/ads")
  end

  def sb_create_brand_video_ads(ads_payload)
    sb_ads_v4.launch_request("/brandVideo", :post, payload: { ads: ads_payload })
  end

  def sb_create_product_collection_extended(ads_payload)
    sb_ads_v4.launch_request("/productCollectionExtended", :post, payload: { ads: ads_payload })
  end

  def sb_create_video_ads(ads_payload)
    sb_ads_v4.launch_request("/video", :post, payload: { ads: ads_payload })
  end

  def sb_create_product_collection(ads_payload)
    sb_ads_v4.launch_request("/productCollection", :post, payload: { ads: ads_payload })
  end

  def sb_create_store_spotlight_ads(ads_payload)
    sb_ads_v4.launch_request("/storeSpotlight", :post, payload: { ads: ads_payload })
  end

  def sb_ad_creatives
    @sb_ad_creatives ||= Blurb::SbV4RequestCollection.new(
      headers: headers_hash,
      resource_type: :ad_creative,
      base_url: "#{account.api_url}/sb/ads/creatives")
  end

  def sb_create_brand_video_ad_creative(payload)
    sb_ad_creatives.launch_request("/brandVideo", :post, payload: )
  end

  # Creates Sponsored Brands new version of product collection with collection of custom image ads
  def sb_create_pce_ad_creative(payload)
    sb_ad_creatives.launch_request("/productCollectionExtended", :post, payload: )
  end

  # Create new version of video ad creative
  def sb_create_video_ad_creative(payload)
    sb_ad_creatives.launch_request("/video", :post, payload: )
  end

  # Create new version of product collection ad creative
  def sb_create_prod_col_ad_creative(payload)
    sb_ad_creatives.launch_request("/productCollection", :post, payload: )
  end

  # Create new version of store spotlight ad creative
  def sb_create_store_sl_ad_creative(payload)
    sb_ad_creatives.launch_request("/storeSpotlight", :post, payload: )
  end

  def sb_recommendations
    @sb_recommendations ||= Blurb::SbV4RequestCollection.new(
      headers: headers_hash,
      resource_type: :recommendation,
      base_url: "#{account.api_url}/sb")
  end

  # Get brand recommendations for negative targeting
  def sb_ng_tg_brand_recs(next_token: nil)
    sb_recommendations.launch_request("/negativeTargets/brands/recommendations", :get, url_params: {next_token: }.compact)
  end

  # Get recommendations for creative headline
  def sb_creative_headline_recs(payload)
    sb_recommendations.launch_request("/recommendations/creative/headline", :post, payload: )
  end

  # Get budget recommendations
  def sb_budget_recs(campaign_ids)
    sb_recommendations.launch_request("/campaigns/budgetRecommendations", :post, payload: {campaignIds: campaign_ids})
  end

  def sb_prod_tg_categories
    @sb_prod_tg_categories ||= Blurb::SbV4RequestCollection.new(
      headers: headers_hash,
      resource_type: :product_targeting_category,
      base_url: "#{account.api_url}/sb/targets")
  end

  # Get targetable categories
  def sb_targetable_categories(supply_source: , locale: nil, only_root_cate: nil, parent_cate_ref_id: nil, next_token: nil)
    sb_prod_tg_categories.launch_request(
      "/categories", :get,
      url_params: {
        supply_source: , locale: , include_only_root_categories: only_root_cate,
        parent_category_refinement_id: parent_cate_ref_id, next_token: }.compact)
  end

  # Get number of products in a category
  def sb_category_products_count(payload)
    sb_prod_tg_categories.launch_request("/products/count", :post, payload: )
  end

  # Get refinements for category
  def sb_category_refinements(cate_ref_id, locale: nil, next_token: nil)
    sb_prod_tg_categories.launch_request(
      "/categories/#{cate_ref_id}/refinements", :get,
      url_params: { locale: , next_token: }.compact)
  end

  # Get insights for campaigns
  def get_sb_insights(payload, next_token: nil)
    @sb_insights ||= Blurb::SbV4RequestCollection.new(
      headers: headers_hash,
      resource_type: :insight,
      base_url: "#{account.api_url}/sb/campaigns/insights")
    @sb_insights.launch_request(nil, :post, payload: , url_params: {next_token: }.compact)
  end

  # Get budget usage
  def get_sb_budget_usage(campaign_ids)
    @sb_budget_usage ||= Blurb::SbV4RequestCollection.new(
      headers: headers_hash,
      resource_type: :budget_usage,
      base_url: "#{account.api_url}/sb/campaigns/budget/usage")
    @sb_budget_usage.launch_request(nil, :post, payload: {campaignIds: campaign_ids})
  end

  # Get performance forecasts for campaigns
  def get_sb_forecasts(campaigns_array)
    @sb_forecasts ||= Blurb::SbV4RequestCollection.new(
      headers: headers_hash,
      resource_type: :forecast,
      base_url: "#{account.api_url}/sb/forecasts")
    @sb_forecasts.launch_request(nil, :post, payload: {campaigns: campaigns_array})
  end

  def sb_budget_rules
    @sb_budget_rules ||= Blurb::SbV4RequestCollection.new(
      headers: headers_hash,
      resource_type: :budget_rule,
      base_url: "#{account.api_url}/sb/budgetRules")
  end

  # Create budget rules
  def sb_create_budget_rules(budget_rules_array)
    sb_budget_rules.launch_request(nil, :post, payload: {budgetRulesDetails: budget_rules_array})
  end

  # Update budget rules
  def sb_update_budget_rules(budget_rules_array)
    sb_budget_rules.launch_request(nil, :put, payload: {budgetRulesDetails: budget_rules_array})
  end

  # Get budget rules
  def get_sb_budget_rules(next_token: nil, size: 30)
    sb_budget_rules.launch_request(nil, :get, url_params: {next_token: , page_size: size}.compact)
  end

  # Get budget rule by ID
  def retrieve_sb_budget_rule(budget_rule_id)
    sb_budget_rules.launch_request("/#{budget_rule_id}", :get)
  end

  # Get campaigns associated with budget rule
  def get_sb_budget_rule_campaigns(budget_rule_id, next_token: nil, size: 30)
    sb_budget_rules.launch_request("/#{budget_rule_id}/campaigns", :get, url_params: {next_token: , page_size: size}.compact)
  end

  def sb_campaign_budget_rules
    @sb_campaign_budget_rules ||= Blurb::SbV4RequestCollection.new(
      headers: headers_hash,
      resource_type: :budget_rule,
      base_url: "#{account.api_url}/sb/campaigns")
  end

  # Associate budget rules to campaign
  def sb_campaign_associate_budget_rules(campaign_id, budget_rule_ids)
    sb_campaign_budget_rules.launch_request("/#{campaign_id}/budgetRules", :post, payload: {budget_rule_ids: })
  end

  def get_sb_campaign_budget_rules(campaign_id)
    sb_campaign_budget_rules.launch_request("/#{campaign_id}/budgetRules", :get)
  end

  # Disassociate budget rule from campaign
  def sb_campaign_disassociate_budget_rule(campaign_id, budget_rule_id)
    sb_campaign_budget_rules.launch_request("/#{campaign_id}/budgetRules/#{budget_rule_id}", :delete)
  end


  # V3
  def sb_targets
    @sb_targets ||= Blurb::SbV3RequestCollection.new(
      headers: headers_hash,
      resource_type: :target,
      base_url: "#{account.api_url}/sb/targets")
  end

  def sb_negative_targets
    @sb_negative_targets ||= Blurb::SbV3RequestCollection.new(
      headers: headers_hash,
      resource_type: :negative_target,
      base_url: "#{account.api_url}/sb/negativeTargets")
  end

  def sb_themes
    @sb_themes ||= Blurb::SbV3RequestCollection.new(
      headers: headers_hash,
      resource_type: :theme,
      base_url: "#{account.api_url}/sb/themes")
  end

  def sb_recommended_targets
    @sb_recommended_targets ||= Blurb::SbV3RequestCollection.new(
      headers: headers_hash,
      resource_type: :recommended_target,
      base_url: "#{account.api_url}/sb/recommendations/targets")
  end

  # Gets a list of recommended products for targeting.
  def sb_recommended_products_list(next_token: nil, size: 100, filters: )
    sb_recommended_targets.launch_request("/product/list", :post, payload: {next_token: , maxResults: size, filters: }.compact)
  end

  # Gets a list of recommended categories for targeting.
  def sb_recommended_categories_list(asins: , supply_source: )
    sb_recommended_targets.launch_request("/category", :post, payload: {asins: , supply_source: }.compact)
  end

  # Gets a list of brand suggestions.
  def sb_recommended_brands_list(category_id: nil, keyword: nil)
    sb_recommended_targets.launch_request("/brand", :post, payload: {category_id: , keyword: }.compact)
  end

  # getBidsRecommendations.
  def get_sb_recommended_bids(payload)
    @sb_recommended_bids ||= Blurb::SbV3RequestCollection.new(
      headers: headers_hash,
      resource_type: :recommended_bid,
      base_url: "#{account.api_url}/sb/recommendations/bids")
    @sb_recommended_bids.launch_request(nil, :post, payload: )
  end

  # Gets a list of special events with suggested date range and suggested budget increase for a campaign specified by identifier.
  def sb_recommend_budget_rules(campaign_id)
    @sb_recommended_budget_rules ||= Blurb::SbV3RequestCollection.new(
      headers: headers_hash,
      resource_type: :budget_rule_recommendation,
      base_url: "#{account.api_url}/sb/campaigns/budgetRules/recommendations")
    @sb_recommended_budget_rules.launch_request(nil, :post, payload: { campaign_id: , recommendationType: "EVENTS_FOR_EXISTING_CAMPAIGN" })
  end

  # Gets keyword recommendations
  def sb_recommend_keywords(payload)
    @sb_recommended_keywords ||= Blurb::SbV3RequestCollection.new(
      headers: headers_hash,
      resource_type: :keyword_recommendation,
      base_url: "#{account.api_url}/sb/recommendations/keyword")
    @sb_recommended_keywords.launch_request(nil, :post, payload: )
  end

  def sb_stores
    @sb_stores ||= Blurb::SbV3RequestCollection.new(
      headers: headers_hash,
      resource_type: :store_asset,
      base_url: "#{account.api_url}/stores/assets")
  end

  # Gets a list of assets associated with a specified brand entity identifier.
  def get_store_assets(brand_entity_id = nil, media_type = nil)
    sb_stores.launch_request(nil, :get, url_params: {brand_entity_id: , media_type: }.compact)
  end

  # Gets ASIN information for a specified address.
  def get_sb_page_asins(page_url)
    @sb_page_asins ||= Blurb::SbV3RequestCollection.new(
      headers: headers_hash,
      resource_type: :page_asin,
      base_url: "#{account.api_url}/pageAsins")
    @sb_page_asins.launch_request(nil, :get, url_params: {page_url: })
  end

  # The API is used to notify that the upload is completed.
  def sb_media
    @sb_media ||= Blurb::SbV3RequestCollection.new(
      headers: headers_hash,
      resource_type: :media,
      base_url: "#{account.api_url}/media")
  end

  # The API is used to notify that the upload is completed.
  def sb_put_media_complete(upload_location: , version: nil)
    sb_media.launch_request("/complete", :put, payload: {upload_location: , version: }.compact)
  end

  # API to poll for media status
  def sb_poll_media_status(media_id)
    sb_media.launch_request("/describe", :get, url_params: {media_id: }.compact)
  end

  # getBrands
  def sb_get_brands(brand_type_filter=nil)
    @sb_brands ||= Blurb::SbV3RequestCollection.new(
      headers: headers_hash,
      resource_type: :brand,
      base_url: "#{account.api_url}/brands")
    @sb_brands.launch_request(nil, :get, url_params: {brand_type_filter: }.compact)
  end

  # Gets the moderation result for a campaign specified by identifier.
  def sb_get_moderation(campaign_id)
    @sb_moderations ||= Blurb::SbV3RequestCollection.new(
      headers: headers_hash,
      resource_type: :moderation,
      base_url: "#{account.api_url}/sb/moderation/campaigns")
    @sb_moderations.launch_request("/#{campaign_id}", :get)
  end

end
